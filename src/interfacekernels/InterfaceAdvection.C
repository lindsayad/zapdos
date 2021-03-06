//* This file is part of Zapdos, an open-source
//* application for the simulation of plasmas
//* https://github.com/shannon-lab/zapdos
//*
//* Zapdos is powered by the MOOSE Framework
//* https://www.mooseframework.org
//*
//* Licensed under LGPL 2.1, please see LICENSE for details
//* https://www.gnu.org/licenses/lgpl-2.1.html

#include "InterfaceAdvection.h"

// MOOSE includes
#include "MooseVariable.h"

#include <cmath>

registerMooseObject("ZapdosApp", InterfaceAdvection);

template <>
InputParameters
validParams<InterfaceAdvection>()
{
  InputParameters params = validParams<InterfaceKernel>();
  params.addRequiredCoupledVar("potential_neighbor",
                               "The potential on the slave side of the interface.");
  params.addRequiredCoupledVar("mean_en_neighbor",
                               "The log of the product of the mean energy and "
                               "electron density on the slave side of the "
                               "interface.");
  params.addRequiredParam<Real>("position_units", "Units of position.");
  params.addRequiredParam<Real>("neighbor_position_units",
                                "The units of position in the neighboring domain.");
  params.addClassDescription(
      "Used to include the electric field driven advective flux of species"
      "into or out of a neighboring subdomain. Currently this interface kernel"
      "is specific to electrons because the transport coefficients are assumed"
      "to be a function of the mean electron energy. A generic interface"
      "kernel with constant transport coefficients will have a much simpler Jacobian");
  return params;
}

InterfaceAdvection::InterfaceAdvection(const InputParameters & parameters)
  : InterfaceKernel(parameters),
    _r_units(1. / getParam<Real>("position_units")),
    _r_neighbor_units(1. / getParam<Real>("neighbor_position_units")),

    _potential_neighbor_var(*getVar("potential_neighbor", 0)),
    _grad_potential_neighbor(_potential_neighbor_var.gradSlnNeighbor()),
    _potential_neighbor_id(coupled("potential_neighbor")),
    _mean_en_neighbor_var(*getVar("mean_en_neighbor", 0)),
    _mean_en_neighbor(_mean_en_neighbor_var.slnNeighbor()),
    _mean_en_neighbor_id(coupled("mean_en_neighbor")),

    _mu_neighbor(getNeighborMaterialProperty<Real>("mu" + _neighbor_var.name())),
    _d_mu_neighbor_d_actual_mean_en(getNeighborMaterialProperty<Real>("d_muem_d_actual_mean_en")),
    _sgn_neighbor(getNeighborMaterialProperty<Real>("sgn" + _neighbor_var.name())),
    _actual_mean_en(0)

{
}

Real
InterfaceAdvection::computeQpResidual(Moose::DGResidualType type)
{
  // if (_mu_neighbor[_qp] < std::numeric_limits<double>::epsilon() || std::abs(_sgn_neighbor[_qp])
  // < std::numeric_limits<double>::epsilon())
  //   mooseError("It doesn't appear that DG material properties got passed.");

  Real r = 0;

  switch (type)
  {
    case Moose::Element:
      r = _mu_neighbor[_qp] * _sgn_neighbor[_qp] * -_grad_potential_neighbor[_qp] *
          _r_neighbor_units * std::exp(_neighbor_value[_qp]) * _normals[_qp] * _test[_i][_qp] *
          _r_units;
      break;

    case Moose::Neighbor:
      r = 0.;
      break;
  }

  return r;
}

Real
InterfaceAdvection::computeQpJacobian(Moose::DGJacobianType type)
{
  Real jac = 0;

  switch (type)
  {
    case Moose::ElementNeighbor:
      _actual_mean_en = std::exp(_mean_en_neighbor[_qp] - _neighbor_value[_qp]);
      jac += _mu_neighbor[_qp] * _sgn_neighbor[_qp] * -_grad_potential_neighbor[_qp] *
                 _r_neighbor_units * std::exp(_neighbor_value[_qp]) * _phi_neighbor[_j][_qp] *
                 _normals[_qp] * _test[_i][_qp] * _r_units +
             _d_mu_neighbor_d_actual_mean_en[_qp] * _actual_mean_en * -_phi_neighbor[_j][_qp] *
                 _sgn_neighbor[_qp] * -_grad_potential_neighbor[_qp] * _r_neighbor_units *
                 std::exp(_neighbor_value[_qp]) * _normals[_qp] * _test[_i][_qp] * _r_units;
      break;

    default:
      break;
  }

  return jac;
}

Real
InterfaceAdvection::computeQpOffDiagJacobian(Moose::DGJacobianType type, unsigned int jvar)
{
  Real r = 0;

  if (jvar == _potential_neighbor_id)
  {
    switch (type)
    {

      case Moose::ElementElement:
        r += 0.;
        break;

      case Moose::ElementNeighbor:
        r += (_mu_neighbor[_qp] * _sgn_neighbor[_qp] * -_grad_phi_neighbor[_j][_qp] *
              _r_neighbor_units * std::exp(_neighbor_value[_qp]) * _normals[_qp]) *
             _test[_i][_qp] * _r_units;
        break;

      case Moose::NeighborElement:
        r += 0.;
        break;

      case Moose::NeighborNeighbor:
        r += 0.;
        break;
    }
  }

  else if (jvar == _mean_en_neighbor_id)
  {
    switch (type)
    {

      case Moose::ElementElement:
        r += 0.;
        break;

      case Moose::ElementNeighbor:
        _actual_mean_en = std::exp(_mean_en_neighbor[_qp] - _neighbor_value[_qp]);
        r += (_d_mu_neighbor_d_actual_mean_en[_qp] * _actual_mean_en * _phi_neighbor[_j][_qp] *
              _sgn_neighbor[_qp] * -_grad_potential_neighbor[_qp] * _r_neighbor_units *
              std::exp(_neighbor_value[_qp]) * _normals[_qp]) *
             _test[_i][_qp] * _r_units;
        break;

      case Moose::NeighborElement:
        r += 0.;
        break;

      case Moose::NeighborNeighbor:
        r += 0.;
        break;
    }
  }

  return r;
}
