//* This file is part of Zapdos, an open-source
//* application for the simulation of plasmas
//* https://github.com/shannon-lab/zapdos
//*
//* Zapdos is powered by the MOOSE Framework
//* https://www.mooseframework.org
//*
//* Licensed under LGPL 2.1, please see LICENSE for details
//* https://www.gnu.org/licenses/lgpl-2.1.html

#include "TotalFlux.h"

registerMooseObject("ZapdosApp", TotalFlux);

template <>
InputParameters
validParams<TotalFlux>()
{
  InputParameters params = validParams<AuxKernel>();

  params.addRequiredCoupledVar("density_log", "The electron density");
  params.addRequiredCoupledVar("potential", "The potential");
  params.addClassDescription("Returns the total flux of defined species");

  return params;
}

TotalFlux::TotalFlux(const InputParameters & parameters)
  : AuxKernel(parameters),

    _density_var(*getVar("density_log", 0)),
    _density_log(coupledValue("density_log")),
    _grad_density_log(coupledGradient("density_log")),
    _grad_potential(coupledGradient("potential")),
    _mu(getMaterialProperty<Real>("mu" + _density_var.name())),
    _sgn(getMaterialProperty<Real>("sgn" + _density_var.name())),
    _diff(getMaterialProperty<Real>("diff" + _density_var.name()))
{
}

Real
TotalFlux::computeValue()
{
  return _sgn[_qp] * _mu[_qp] * -_grad_potential[_qp](0) * std::exp(_density_log[_qp]) -
         _diff[_qp] * std::exp(_density_log[_qp]) * _grad_density_log[_qp](0);
}
