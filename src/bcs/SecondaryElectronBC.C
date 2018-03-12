#include "SecondaryElectronBC.h"

// MOOSE includes
#include "MooseVariable.h"

template <>
InputParameters
validParams<SecondaryElectronBC>()
{
  InputParameters params = validParams<IntegratedBC>();
  params.addRequiredParam<Real>("r", "The reflection coefficient");
  params.addRequiredCoupledVar("potential", "The electric potential");
  params.addCoupledVar("mean_en", 3, "The mean energy.");
  params.addRequiredCoupledVar("ip", "The ion density.");
  params.addRequiredParam<Real>(
      "characteristic_efield",
      "The characteristic electric field strength. Must be in units of volts per meter.");
  params.addRequiredParam<Real>("characteristic_mobility",
                                "The characteristic mobility in units of m^2 / (V*s)");
  return params;
}

SecondaryElectronBC::SecondaryElectronBC(const InputParameters & parameters)
  : IntegratedBC(parameters),

    _r(getParam<Real>("r")),

    // Coupled Variables
    _grad_potential(coupledGradient("potential")),
    _potential_id(coupled("potential")),
    _ip_var(*getVar("ip", 0)),
    _ip(coupledValue("ip")),
    _grad_ip(coupledGradient("ip")),
    _ip_id(coupled("ip")),

    _muem(getMaterialProperty<Real>("muem")),
    _massem(getMaterialProperty<Real>("massem")),
    _e(getMaterialProperty<Real>("e")),
    _sgnip(getMaterialProperty<Real>("sgn" + _ip_var.name())),
    _muip(getMaterialProperty<Real>("mu" + _ip_var.name())),
    _Dip(getMaterialProperty<Real>("diff" + _ip_var.name())),
    _se_coeff(getMaterialProperty<Real>("se_coeff")),
    _a(0.5),
    _v_thermal(0),
    _ion_flux(0, 0, 0),
    _n_gamma(0),
    _d_v_thermal_d_u(0),
    _d_ion_flux_d_potential(0, 0, 0),
    _d_ion_flux_d_ip(0, 0, 0),
    _d_n_gamma_d_potential(0),
    _d_n_gamma_d_ip(0),
    _d_n_gamma_d_u(0),
    _E0(getParam<Real>("characteristic_efield")),
    _mu0(getParam<Real>("characteristic_mobility")),
    _mean_energy(getMaterialProperty<Real>("actual_mean_energy"))
{
}

Real
SecondaryElectronBC::computeQpResidual()
{
  if (_normals[_qp] * -1.0 * -_grad_potential[_qp] > 0.0)
  {
    _a = 1.0;
  }
  else
  {
    _a = 0.0;
  }

  _ion_flux = _sgnip[_qp] * _muip[_qp] * -_grad_potential[_qp] * std::exp(_ip[_qp]) -
              _Dip[_qp] * std::exp(_ip[_qp]) * _grad_ip[_qp];
  _n_gamma =
      (1. - _a) * _se_coeff[_qp] * _ion_flux * _normals[_qp] /
      (_muem[_qp] * -_grad_potential[_qp] * _normals[_qp] + std::numeric_limits<double>::epsilon());
  _v_thermal =
      std::sqrt(8 * _e[_qp] * 2.0 / 3 * _mean_energy[_qp] / (M_PI * _massem[_qp])) / (_mu0 * _E0);

  return _test[_i][_qp] * (1. - _r) / (1. + _r) * (-0.5 * _v_thermal * _n_gamma) -
         _test[_i][_qp] * 2. / (1. + _r) * (1. - _a) * _se_coeff[_qp] * _ion_flux * _normals[_qp];
}

Real
SecondaryElectronBC::computeQpJacobian()
{
  return 0.;
}

Real
SecondaryElectronBC::computeQpOffDiagJacobian(unsigned int /*jvar*/)
{
  return 0;
}
