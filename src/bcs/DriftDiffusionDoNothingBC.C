#include "DriftDiffusionDoNothingBC.h"

// MOOSE includes
#include "MooseVariable.h"

template <>
InputParameters
validParams<DriftDiffusionDoNothingBC>()
{
  InputParameters params = validParams<IntegratedBC>();
  params.addCoupledVar(
      "potential", "The gradient of the potential will be used to compute the advection velocity.");
  return params;
}

DriftDiffusionDoNothingBC::DriftDiffusionDoNothingBC(const InputParameters & parameters)
  : IntegratedBC(parameters),

    _mu(getMaterialProperty<Real>("mu" + _var.name())),
    _sign(getMaterialProperty<Real>("sgn" + _var.name())),
    _diffusivity(getMaterialProperty<Real>("diff" + _var.name())),

    // Coupled variables
    _potential_id(coupled("potential")),
    _grad_potential(coupledGradient("potential"))
{
}

DriftDiffusionDoNothingBC::~DriftDiffusionDoNothingBC() {}

Real
DriftDiffusionDoNothingBC::computeQpResidual()
{
  return _mu[_qp] * _sign[_qp] * std::exp(_u[_qp]) * -_grad_potential[_qp] * _normals[_qp] *
             _test[_i][_qp] -
         _diffusivity[_qp] * std::exp(_u[_qp]) * _grad_u[_qp] * _normals[_qp] * _test[_i][_qp];
}

Real
DriftDiffusionDoNothingBC::computeQpJacobian()
{
  return 0.;
}

Real
DriftDiffusionDoNothingBC::computeQpOffDiagJacobian(unsigned int /*jvar*/)
{
  return 0.;
}
