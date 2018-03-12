#include "CoeffDiffusionLin.h"

// MOOSE includes
#include "MooseVariable.h"

template <>
InputParameters
validParams<CoeffDiffusionLin>()
{
  InputParameters params = validParams<Diffusion>();
  return params;
}

// This diffusion kernel should only be used with species whose values are in the logarithmic form.

CoeffDiffusionLin::CoeffDiffusionLin(const InputParameters & parameters)
  : Diffusion(parameters),

    _diffusivity(getMaterialProperty<Real>("diff" + _var.name()))
{
}

CoeffDiffusionLin::~CoeffDiffusionLin() {}

Real
CoeffDiffusionLin::computeQpResidual()
{
  return -_diffusivity[_qp] * _grad_u[_qp] * -_grad_test[_i][_qp];
}

Real
CoeffDiffusionLin::computeQpJacobian()
{
  return -_diffusivity[_qp] * _grad_phi[_j][_qp] * -_grad_test[_i][_qp];
}
