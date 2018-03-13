#include "Efield.h"

template <>
InputParameters
validParams<Efield>()
{
  InputParameters params = validParams<AuxKernel>();

  params.addRequiredCoupledVar("potential", "The potential");
  params.addRequiredParam<int>("component",
                               "The component of the electric field to access. Accepts an integer");
  return params;
}

Efield::Efield(const InputParameters & parameters)
  : AuxKernel(parameters),

    _component(getParam<int>("component")),
    _grad_potential(coupledGradient("potential"))
{
}

Real
Efield::computeValue()
{
  return -_grad_potential[_qp](_component);
}
