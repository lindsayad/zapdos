/****************************************************************/
/*               DO NOT MODIFY THIS HEADER                      */
/* MOOSE - Multiphysics Object Oriented Simulation Environment  */
/*                                                              */
/*           (c) 2010 Battelle Energy Alliance, LLC             */
/*                   ALL RIGHTS RESERVED                        */
/*                                                              */
/*          Prepared by Battelle Energy Alliance, LLC           */
/*            Under Contract No. DE-AC07-05ID14517              */
/*            With the U. S. Department of Energy               */
/*                                                              */
/*            See COPYRIGHT for full restrictions               */
/****************************************************************/

#ifndef IONIZATIONSOURCEEFIELD_H
#define IONIZATIONSOURCEEFIELD_H

#include "Kernel.h"

class IonizationSourceEField;

template <>
InputParameters validParams<IonizationSourceEField>();

class IonizationSourceEField : public Kernel
{
public:
  IonizationSourceEField(const InputParameters & parameters);
  virtual ~IonizationSourceEField();

protected:
  virtual Real computeQpResidual();
  virtual Real computeQpJacobian();
  virtual Real computeQpOffDiagJacobian(unsigned int jvar);

  const MaterialProperty<Real> & _diffem;
  const MaterialProperty<Real> & _muem;
  const MaterialProperty<Real> & _alpha_iz;

  const VariableGradient & _grad_potential;
  unsigned int _potential_id;
  const VariableValue & _em;
  const VariableGradient & _grad_em;
  unsigned int _em_id;
};

#endif /* IONIZATIONSOURCEEFIELD_H */
