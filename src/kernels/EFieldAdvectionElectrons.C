//* This file is part of Zapdos, an open-source
//* application for the simulation of plasmas
//* https://github.com/shannon-lab/zapdos
//*
//* Zapdos is powered by the MOOSE Framework
//* https://www.mooseframework.org
//*
//* Licensed under LGPL 2.1, please see LICENSE for details
//* https://www.gnu.org/licenses/lgpl-2.1.html

#include "EFieldAdvectionElectrons.h"

registerMooseObject("ZapdosApp", EFieldAdvectionElectrons);

template <>
InputParameters
validParams<EFieldAdvectionElectrons>()
{
  InputParameters params = validParams<Kernel>();
  params.addRequiredCoupledVar(
      "potential", "The gradient of the potential will be used to compute the advection velocity.");
  params.addRequiredCoupledVar("mean_en", "The log of the mean energy.");
  params.addRequiredParam<Real>("position_units", "The units of position.");
  params.addClassDescription("Electron specific electric field driven advection term"
                             "(Electron density must be in log form)");
  return params;
}

EFieldAdvectionElectrons::EFieldAdvectionElectrons(const InputParameters & parameters)
  : Kernel(parameters),

    _position_units(1. / getParam<Real>("position_units")),

    _muem(getMaterialProperty<Real>("muem")),
    _d_muem_d_actual_mean_en(getMaterialProperty<Real>("d_muem_d_actual_mean_en")),
    _sign(getMaterialProperty<Real>("sgnem")),

    // Coupled variables

    _potential_id(coupled("potential")),
    _grad_potential(coupledGradient("potential")),
    _mean_en(coupledValue("mean_en")),
    _mean_en_id(coupled("mean_en")),

    _d_actual_mean_en_d_mean_en(0),
    _d_muem_d_mean_en(0),
    _d_actual_mean_en_d_u(0),
    _d_muem_d_u(0)
{
}

Real
EFieldAdvectionElectrons::computeQpResidual()
{
  return _muem[_qp] * _sign[_qp] * std::exp(_u[_qp]) * -_grad_potential[_qp] * _position_units *
         -_grad_test[_i][_qp] * _position_units;
}

Real
EFieldAdvectionElectrons::computeQpJacobian()
{
  _d_actual_mean_en_d_u = std::exp(_mean_en[_qp] - _u[_qp]) * -_phi[_j][_qp];
  _d_muem_d_u = _d_muem_d_actual_mean_en[_qp] * _d_actual_mean_en_d_u;

  return (_d_muem_d_u * _sign[_qp] * std::exp(_u[_qp]) * -_grad_potential[_qp] * _position_units +
          _muem[_qp] * _sign[_qp] * std::exp(_u[_qp]) * _phi[_j][_qp] * -_grad_potential[_qp] *
              _position_units) *
         -_grad_test[_i][_qp] * _position_units;
}

Real
EFieldAdvectionElectrons::computeQpOffDiagJacobian(unsigned int jvar)
{
  if (jvar == _potential_id)
  {
    return _muem[_qp] * _sign[_qp] * std::exp(_u[_qp]) * -_grad_phi[_j][_qp] * _position_units *
           -_grad_test[_i][_qp] * _position_units;
  }

  if (jvar == _mean_en_id)
  {
    _d_actual_mean_en_d_mean_en = std::exp(_mean_en[_qp] - _u[_qp]) * _phi[_j][_qp];
    _d_muem_d_mean_en = _d_muem_d_actual_mean_en[_qp] * _d_actual_mean_en_d_mean_en;

    return _d_muem_d_mean_en * _sign[_qp] * std::exp(_u[_qp]) * -_grad_potential[_qp] *
           _position_units * -_grad_test[_i][_qp] * _position_units;
  }

  else
    return 0.0;
}
