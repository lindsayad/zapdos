#include "IonizationSourceEField.h"

// MOOSE includes
#include "MooseVariable.h"

template <>
InputParameters
validParams<IonizationSourceEField>()
{
  InputParameters params = validParams<Kernel>();
  params.addCoupledVar("potential", "The potential.");
  params.addRequiredCoupledVar("em", "The electron density in logarithmic form.");
  return params;
}

IonizationSourceEField::IonizationSourceEField(const InputParameters & parameters)
  : Kernel(parameters),
    _diffem(getMaterialProperty<Real>("diffem")),
    _muem(getMaterialProperty<Real>("muem")),
    _alpha_iz(getMaterialProperty<Real>("alpha_iz")),
    _grad_potential(coupledGradient("potential")),
    _potential_id(coupled("potential")),
    _em(coupledValue("em")),
    _grad_em(coupledGradient("em")),
    _em_id(coupled("em"))
{
}

IonizationSourceEField::~IonizationSourceEField() {}

Real
IonizationSourceEField::computeQpResidual()
{
  Real electron_flux_mag = (-_muem[_qp] * -_grad_potential[_qp] * std::exp(_em[_qp]) -
                            _diffem[_qp] * std::exp(_em[_qp]) * _grad_em[_qp])
                               .norm();
  Real iz_term =
      _alpha_iz[_qp] * std::exp(-1.25e-1 / _grad_potential[_qp].norm()) * electron_flux_mag;

  return -_test[_i][_qp] * iz_term;
}

Real
IonizationSourceEField::computeQpJacobian()
{
  return 0;
}

Real
IonizationSourceEField::computeQpOffDiagJacobian(unsigned int /*jvar*/)
{
  return 0.0;
}
