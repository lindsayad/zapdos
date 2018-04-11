/****************************************************************/
/*               DO NOT MODIFY THIS HEADER                      */
/* MOOSE - Multiphysics Object Oriented Simulation Environment  */
/*                                                              */
/*           (c) 2010 Battelle Energy Alliance, LLC             */
/*                   ALL RIGHTS RESERVED                        */
/*                                                              */
/*          Prepared by Battelle Energy Alliance, LLC           */
/*            Under Contract No. DE-AC07-05ID14517              */
/*            With the U. S. Department of Energy               */
/*                                                              */
/*            See COPYRIGHT for full restrictions               */
/****************************************************************/

#include "FluxInterface.h"

// MOOSE includes
#include "MooseVariable.h"

#include <cmath>

template <>
InputParameters
validParams<FluxInterface>()
{
  InputParameters params = validParams<InterfaceKernel>();
  params.addRequiredParam<std::string>("region_name", "The name of the primary region.");
  params.addRequiredParam<std::string>("neighbor_region_name", "The name of the slave region.");
  params.addRequiredParam<Real>("position_units", "Units of position.");
  params.addRequiredParam<Real>("neighbor_position_units",
                                "The units of position in the neighboring domain.");
  return params;
}

FluxInterface::FluxInterface(const InputParameters & parameters)
  : InterfaceKernel(parameters),
    _r_units(1. / getParam<Real>("position_units")),
    _r_neighbor_units(1. / getParam<Real>("neighbor_position_units")),

    // _sigma(getMaterialProperty<Real>("sigma")),
    _diff_main(getMaterialProperty<Real>("diffpotential_" + getParam<std::string>("region_name"))),
    _diff_neighbor(getNeighborMaterialProperty<Real>("diffpotential_" + getParam<std::string>("neighbor_region_name")))
{
  if (!parameters.isParamValid("boundary"))
  {
    mooseError("In order to use the InterfaceDiffusion dgkernel, you must specify a boundary where "
               "it will live.");
  }
}

Real
FluxInterface::computeQpResidual(Moose::DGResidualType type)
{
  Real r = -_diff_main[_qp] * _grad_u[_qp] * _normals[_qp] +
                  -_diff_neighbor[_qp] * _grad_neighbor_value[_qp] * _normals[_qp];

  switch (type)
  {
    case Moose::Element:
      r *= _test[_i][_qp];
      break;

    case Moose::Neighbor:
      r *= -_test_neighbor[_i][_qp];
      break;
  }

  return r;
}

Real
FluxInterface::computeQpJacobian(Moose::DGJacobianType type)
{
  Real jac = 0;

  switch (type)
  {

    case Moose::ElementElement:
      jac -= _diff_main[_qp] * _grad_phi[_j][_qp] * _normals[_qp] * _test[_i][_qp];
      break;

    case Moose::NeighborNeighbor:
      jac += _diff_neighbor[_qp] * _grad_phi_neighbor[_j][_qp] * _normals[_qp] * _test_neighbor[_i][_qp];
      break;

    case Moose::NeighborElement:
      jac += _diff_main[_qp] * _grad_phi[_j][_qp] * _normals[_qp] * _test_neighbor[_i][_qp];
      break;

    case Moose::ElementNeighbor:
      jac -= _diff_neighbor[_qp] * _grad_phi_neighbor[_j][_qp] * _normals[_qp] * _test[_i][_qp];
      break;
  }

  return jac;
}
