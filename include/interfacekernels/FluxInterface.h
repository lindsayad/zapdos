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

#ifndef FLUXINTERFACE_H
#define FLUXINTERFACE_H

#include "InterfaceKernel.h"

// Forward Declarations
class FluxInterface;

template <>
InputParameters validParams<FluxInterface>();

/**
 * DG kernel for interfacing scalar discontinuities on adjacent blocks
 * For example, a discontinuity in the potential due to a dielectric surface
 */
class FluxInterface : public InterfaceKernel
{
public:
  FluxInterface(const InputParameters & parameters);

protected:
  virtual Real computeQpResidual(Moose::DGResidualType type);
  virtual Real computeQpJacobian(Moose::DGJacobianType type);
  //virtual Real computeQpOffDiagJacobian(Moose::DGJacobianType type, unsigned int jvar);

  Real _r_units;
  Real _r_neighbor_units;

  // const MaterialProperty<Real> & _sigma;
  const MaterialProperty<Real> & _diff_main;
  const MaterialProperty<Real> & _diff_neighbor;

  // const MaterialProperty<Real> & _sgn_neighbor;
};

#endif
