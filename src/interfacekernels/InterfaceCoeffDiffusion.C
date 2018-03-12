#include "InterfaceCoeffDiffusion.h"

// MOOSE includes
#include "MooseVariable.h"

#include <cmath>

template <>
InputParameters
validParams<InterfaceCoeffDiffusion>()
{
  InputParameters params = validParams<InterfaceKernel>();
  params.addRequiredParam<Real>("position_units", "Units of position.");
  params.addRequiredParam<Real>("neighbor_position_units",
                                "The units of position in the neighboring domain.");
  return params;
}

InterfaceCoeffDiffusion::InterfaceCoeffDiffusion(const InputParameters & parameters)
  : InterfaceKernel(parameters),
    _r_units(1. / getParam<Real>("position_units")),
    _r_neighbor_units(1. / getParam<Real>("neighbor_position_units")),
    _diffusivity(getMaterialProperty<Real>("diff" + _var.name()))
{
}

Real
InterfaceCoeffDiffusion::computeQpResidual(Moose::DGResidualType type)
{
  Real r = 0;

  switch (type)
  {
    case Moose::Element:
      r = -_diffusivity[_qp] * _grad_neighbor_value[_qp] * _r_neighbor_units * _normals[_qp] *
          _test[_i][_qp] * _r_units;
      break;

    case Moose::Neighbor:
      r = 0.;
      break;
  }

  return r;
}

Real
InterfaceCoeffDiffusion::computeQpJacobian(Moose::DGJacobianType type)
{
  Real jac = 0;
  switch (type)
  {
    case Moose::ElementNeighbor:
      jac += -_diffusivity[_qp] * _grad_phi_neighbor[_j][_qp] * _r_neighbor_units * _normals[_qp] *
             _test[_i][_qp] * _r_units;
      break;

    default:
      break;
  }

  return jac;
}

Real
InterfaceCoeffDiffusion::computeQpOffDiagJacobian(Moose::DGJacobianType /*type*/,
                                                  unsigned int /*jvar*/)
{
  return 0.;
}
