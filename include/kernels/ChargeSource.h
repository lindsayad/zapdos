#ifndef CHARGESOURCE_H
#define CHARGESOURCE_H

#include "Kernel.h"

class ChargeSource;

template <>
InputParameters validParams<ChargeSource>();

class ChargeSource : public Kernel
{
public:
  ChargeSource(const InputParameters & parameters);
  virtual ~ChargeSource();

protected:
  virtual Real computeQpResidual() override;
  virtual Real computeQpJacobian() override;
  virtual Real computeQpOffDiagJacobian(unsigned int jvar) override;

  // coupled vars

  MooseVariable & _charged_var;
  const VariableValue & _charged;
  unsigned int _charged_id;

  const MaterialProperty<Real> & _sgn;
};

#endif /* CHARGESOURCE_H */
