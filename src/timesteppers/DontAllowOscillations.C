//* This file is part of the MOOSE framework
//* https://www.mooseframework.org
//*
//* All rights reserved, see COPYRIGHT for full restrictions
//* https://github.com/idaholab/moose/blob/master/COPYRIGHT
//*
//* Licensed under LGPL 2.1, please see LICENSE for details
//* https://www.gnu.org/licenses/lgpl-2.1.html

#include "DontAllowOscillations.h"

registerMooseObject("MooseApp", DontAllowOscillations);

template <>
InputParameters
validParams<DontAllowOscillations>()
{
  InputParameters params = validParams<IterationAdaptiveDT>();
  params.addRequiredParam<PostprocessorName>("postprocessor",
                                             "The name of the postprocessor that computes the dt");
  params.addParam<Real>(
      "active_start_time", 0, "When this postprocessor criterion becomes active.");
  return params;
}

DontAllowOscillations::DontAllowOscillations(const InputParameters & parameters)
  : IterationAdaptiveDT(parameters),
    _pps_value(getPostprocessorValue("postprocessor")),
    _pps_value_old(getPostprocessorValueOld("postprocessor")),
    _pps_value_older(getPostprocessorValueOlder("postprocessor")),
    _active_time(getParam<Real>("active_start_time"))
{
}

void
DontAllowOscillations::step()
{
  TimeStepper::step();
  if (_time > _active_time)
  {
    std::cout << "Im inside the loop!" << std::endl;
    if ((_pps_value > _pps_value_old && _pps_value_old < _pps_value_older) ||
        (_pps_value < _pps_value_old && _pps_value_old > _pps_value_older))
    {
      _converged = false;
      std::cout << "Cutting time step because we're oscillating!!!" << std::endl;
    }
  }
}
