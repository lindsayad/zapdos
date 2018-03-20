//* This file is part of the MOOSE framework
//* https://www.mooseframework.org
//*
//* All rights reserved, see COPYRIGHT for full restrictions
//* https://github.com/idaholab/moose/blob/master/COPYRIGHT
//*
//* Licensed under LGPL 2.1, please see LICENSE for details
//* https://www.gnu.org/licenses/lgpl-2.1.html

#ifndef DONTALLOWOSCILLATIONS_H
#define DONTALLOWOSCILLATIONS_H

#include "IterationAdaptiveDT.h"
#include "PostprocessorInterface.h"

class DontAllowOscillations;

template <>
InputParameters validParams<DontAllowOscillations>();

/**
 * Computes the value of dt based on a postprocessor value
 */
class DontAllowOscillations : public IterationAdaptiveDT
{
public:
  DontAllowOscillations(const InputParameters & parameters);

  virtual void step() override;

protected:
  const PostprocessorValue & _pps_value;
  const PostprocessorValue & _pps_value_old;
  const PostprocessorValue & _pps_value_older;

  const Real _active_time;
};

#endif /* DONTALLOWOSCILLATIONS_H */
