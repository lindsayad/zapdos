#include "SideTotFluxIntegral.h"

// MOOSE includes
#include "MooseVariable.h"

template <>
InputParameters
validParams<SideTotFluxIntegral>()
{
  InputParameters params = validParams<SideIntegralPostprocessor>();
  params.addRequiredCoupledVar("potential", "The potential that drives the advective flux.");
  params.addRequiredCoupledVar("ip", "The ion density in log form");
  params.addRequiredCoupledVar("em", "The electron density in log form");
  return params;
}

SideTotFluxIntegral::SideTotFluxIntegral(const InputParameters & parameters)
  : SideIntegralPostprocessor(parameters),
    _ip_var(*getVar("ip", 0)),
    _muem(getMaterialProperty<Real>("muem")),
    _muip(getMaterialProperty<Real>("mu" + _ip_var.name())),
    _diffem(getMaterialProperty<Real>("diffem")),
    _diffip(getMaterialProperty<Real>("diff" + _ip_var.name())),

    _grad_potential(coupledGradient("potential")),
    _grad_em(coupledGradient("em")),
    _em(coupledValue("em")),
    _grad_ip(coupledGradient("ip")),
    _ip(coupledValue("ip"))
{
}

Real
SideTotFluxIntegral::computeQpIntegral()
{
  return (-_muem[_qp] * std::exp(_em[_qp]) * _grad_potential[_qp] +
          _diffem[_qp] * std::exp(_em[_qp]) * _grad_em[_qp] -
          _muip[_qp] * std::exp(_ip[_qp]) * _grad_potential[_qp] -
          _diffip[_qp] * std::exp(_ip[_qp]) * _grad_ip[_qp]) *
         _normals[_qp];
}
