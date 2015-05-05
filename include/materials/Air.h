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
#ifndef AIR_H_
#define AIR_H_

#include "Material.h"

// A helper class from MOOSE that linear interpolates x,y data
#include "LinearInterpolation.h"

class Air;

template<>
InputParameters validParams<Air>();

/**
 * Material objects inherit from Material and override computeQpProperties.
 *
 * Their job is to declare properties for use by other objects in the
 * calculation such as Kernels and BoundaryConditions.
 */
class Air : public Material
{
public:
  Air(const std::string & name, InputParameters parameters);

protected:
  /**
   * Necessary override.  This is where the values of the properties
   * are computed.
   */
  virtual void computeQpProperties();

  // Input parameters
  
  const Real & _velocity_multiplier;
  const Real & _relative_permittivity;
  const Real & _ionization_multiplier;
  const Real & _user_potential_mult;
  const Real & _user_density_mult;
  const Real & _user_diffusivity;
  const Real & _delta;

  // Coupled Variables

  VariableGradient & _grad_potential;

  // Material properties
  
  MaterialProperty<Real> & _velocity_coeff;
  MaterialProperty<Real> & _permittivity;
  MaterialProperty<Real> & _coulomb_charge;
  MaterialProperty<Real> & _ionization_coeff;
  MaterialProperty<Real> & _ion_activation_energy;
  MaterialProperty<Real> & _potential_mult;
  MaterialProperty<Real> & _density_mult;
  MaterialProperty<Real> & _peclet_num;
  MaterialProperty<Real> & _alpha; 
  MaterialProperty<RealVectorValue> & _velocity;
  MaterialProperty<RealVectorValue> & _velocity_norm;
  MaterialProperty<Real> & _diffusivity;
  MaterialProperty<Real> & _tau;
};

#endif //AIR_H