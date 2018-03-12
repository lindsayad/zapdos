#include "NeumannCircuitVoltage.h"

// MOOSE includes
#include "MooseVariable.h"
#include "Function.h"

template <>
InputParameters
validParams<NeumannCircuitVoltage>()
{
  InputParameters params = validParams<IntegratedBC>();
  params.addRequiredParam<FunctionName>("function", "The function.");
  params.addRequiredParam<UserObjectName>(
      "data_provider",
      "The name of the UserObject that can provide some data to materials, bcs, etc.");
  params.addRequiredCoupledVar("ip", "The ion density.");
  params.addRequiredCoupledVar("em", "The log of the electron density.");
  params.addRequiredCoupledVar(
      "mean_en", "The log of the product of the mean energy and the electron density.");
  params.addRequiredParam<Real>("r",
                                "The reflection coefficient applied to both electrons and ions");
  params.addRequiredParam<Real>(
      "characteristic_length",
      "The characteristic length to be used for this simulation. Must be in units of meters.");
  params.addRequiredParam<Real>(
      "characteristic_efield",
      "The characteristic electric field strength. Must be in units of volts per meter.");
  params.addRequiredParam<Real>("characteristic_mobility",
                                "The characteristic mobility in units of m^2 / (V*s)");

  return params;
}

NeumannCircuitVoltage::NeumannCircuitVoltage(const InputParameters & parameters)
  : IntegratedBC(parameters),
    _V_bat(getFunction("function")),
    _data(getUserObject<ProvideMobility>("data_provider")),
    _ip_var(*getVar("ip", 0)),
    _ip(coupledValue("ip")),
    _grad_ip(coupledGradient("ip")),
    _ip_id(coupled("ip")),
    _mean_en(coupledValue("mean_en")),
    _mean_en_id(coupled("mean_en")),
    _em(coupledValue("em")),
    _grad_em(coupledGradient("em")),
    _em_id(coupled("em")),
    _se_coeff(getMaterialProperty<Real>("se_coeff")),
    _muip(getMaterialProperty<Real>("mu" + _ip_var.name())),
    _eps(8.85e-12),
    _sgnip(getMaterialProperty<Real>("sgn" + _ip_var.name())),
    _Dip(getMaterialProperty<Real>("diff" + _ip_var.name())),
    _muem(getMaterialProperty<Real>("muem")),
    _d_muem_d_actual_mean_en(getMaterialProperty<Real>("d_muem_d_actual_mean_en")),
    _diffem(getMaterialProperty<Real>("diffem")),
    _e(1.6e-19),
    _massem(getMaterialProperty<Real>("massem")),
    _T_heavy(getMaterialProperty<Real>("T" + _ip_var.name())),
    _kb(getMaterialProperty<Real>("k_boltz")),
    _mass(getMaterialProperty<Real>("mass" + _ip_var.name())),

    _r(getParam<Real>("r")),
    _ion_flux(0, 0, 0),
    _n_gamma(0),
    _actual_mean_en(0),
    _v_e_th(0),
    _d_v_e_th_d_em(0),
    _d_v_e_th_d_mean_en(0),
    _v_i_th(0),
    _a(0),
    _b(0),
    _d_ion_flux_d_u(0, 0, 0),
    _d_ion_flux_d_ip(0, 0, 0),
    _d_n_gamma_d_u(0),
    _d_n_gamma_d_ip(0),
    _d_n_gamma_d_em(0),
    _d_n_gamma_d_mean_en(0),
    _numerator(0),
    _denominator(0),
    _d_numerator_d_u(0),
    _d_denominator_d_u(0),
    _d_numerator_d_ip(0),
    _d_denominator_d_ip(0),
    _d_numerator_d_em(0),
    _d_denominator_d_em(0),
    _d_numerator_d_mean_en(0),
    _d_denominator_d_mean_en(0),
    _mu0(getParam<Real>("characteristic_mobility")),
    _l0(getParam<Real>("characteristic_length")),
    _E0(getParam<Real>("characteristic_efield"))
{
}

Real
NeumannCircuitVoltage::computeQpResidual()
{
  if (_normals[_qp] * -1.0 * -_grad_u[_qp] > 0.0)
  {
    _a = 1.0;
    _b = 0.;
  }
  else
  {
    _a = 0.0;
    _b = 1.;
  }

  _ion_flux = _sgnip[_qp] * _muip[_qp] * -_grad_u[_qp] * std::exp(_ip[_qp]) -
              _Dip[_qp] * std::exp(_ip[_qp]) * _grad_ip[_qp];
  _n_gamma = (1. - _a) * _se_coeff[_qp] * _ion_flux * _normals[_qp] /
             (_muem[_qp] * -_grad_u[_qp] * _normals[_qp] + std::numeric_limits<double>::epsilon());
  _v_e_th =
      std::sqrt(8 * _e * 2.0 / 3 * std::exp(_mean_en[_qp] - _em[_qp]) / (M_PI * _massem[_qp])) /
      (_mu0 * _E0);
  _v_i_th = std::sqrt(8 * _kb[_qp] * _T_heavy[_qp] / (M_PI * _mass[_qp])) / (_mu0 * _E0);

  return _test[_i][_qp] *
         (-2. * (1. + _r) * (_u[_qp] + _V_bat.value(_t, _q_point[_qp])) * _e /
              (_eps * _E0 * _l0 * _l0 * _data.electrode_area() * _data.ballast_resist()) +
          (-1. + _r) * ((-1. + (-1. + _a) * _se_coeff[_qp]) * std::exp(_ip[_qp]) * _v_i_th +
                        (std::exp(_em[_qp]) - _n_gamma) * _v_e_th)) /
         (2. * (-1. + _r) *
          ((-1. + 2. * _a) * _muem[_qp] * (std::exp(_em[_qp]) - _n_gamma) -
           (-1. + 2. * _b) * (-1. + (-1. + _a) * _se_coeff[_qp]) * _muip[_qp] *
               std::exp(_ip[_qp])));
  // return -_test[_i][_qp] *
  //        ((_u[_qp] + _V_bat.value(_t, _q_point[_qp])) * _e /
  //             (_eps * _E0 * _l0 * _l0 * _data.electrode_area() * _data.ballast_resist()) +
  //         _normals[_qp] * (_Dip[_qp] * _grad_ip[_qp] * std::exp(_ip[_qp]) -
  //                          _diffem[_qp] * _grad_em[_qp] * std::exp(_em[_qp]))) /
  //        (_muip[_qp] * std::exp(_ip[_qp]) + _muem[_qp] * std::exp(_em[_qp]));
}

Real
NeumannCircuitVoltage::computeQpJacobian()
{
  if (_normals[_qp] * -1.0 * -_grad_u[_qp] > 0.0)
  {
    _a = 1.0;
    _b = 0.;
  }
  else
  {
    _a = 0.0;
    _b = 1.;
  }

  _ion_flux = _sgnip[_qp] * _muip[_qp] * -_grad_u[_qp] * std::exp(_ip[_qp]) -
              _Dip[_qp] * std::exp(_ip[_qp]) * _grad_ip[_qp];
  _d_ion_flux_d_u = _sgnip[_qp] * _muip[_qp] * -_grad_phi[_j][_qp] * std::exp(_ip[_qp]);
  _n_gamma = (1. - _a) * _se_coeff[_qp] * _ion_flux * _normals[_qp] /
             (_muem[_qp] * -_grad_u[_qp] * _normals[_qp] + std::numeric_limits<double>::epsilon());
  _d_n_gamma_d_u = (1. - _a) * _se_coeff[_qp] / _muem[_qp] *
                   (_d_ion_flux_d_u * _normals[_qp] / (-_grad_u[_qp] * _normals[_qp]) -
                    _ion_flux * _normals[_qp] / (std::pow(-_grad_u[_qp] * _normals[_qp], 2.)) *
                        -_grad_phi[_j][_qp] * _normals[_qp]);
  _v_e_th =
      std::sqrt(8 * _e * 2.0 / 3 * std::exp(_mean_en[_qp] - _em[_qp]) / (M_PI * _massem[_qp])) /
      (_mu0 * _E0);
  _v_i_th = std::sqrt(8 * _kb[_qp] * _T_heavy[_qp] / (M_PI * _mass[_qp])) / (_mu0 * _E0);

  _numerator = (-2. * (1. + _r) * (_u[_qp] + _V_bat.value(_t, _q_point[_qp])) * _e /
                    (_eps * _E0 * _l0 * _l0 * _data.electrode_area() * _data.ballast_resist()) +
                (-1. + _r) * ((-1. + (-1. + _a) * _se_coeff[_qp]) * std::exp(_ip[_qp]) * _v_i_th +
                              (std::exp(_em[_qp]) - _n_gamma) * _v_e_th));
  _denominator =
      (2. *
       ((-1. + 2. * _a) * _muem[_qp] * (std::exp(_em[_qp]) - _n_gamma) -
        (-1. + 2. * _b) * (-1. + (-1. + _a) * _se_coeff[_qp]) * _muip[_qp] * std::exp(_ip[_qp])) *
       (-1. + _r));

  _d_denominator_d_u = 2. * (-1. + _r) * (-1. + 2. * _a) * _muem[_qp] * -_d_n_gamma_d_u;
  _d_numerator_d_u =
      -2. * (1. + _r) * _phi[_j][_qp] * _e /
          (_eps * _E0 * _l0 * _l0 * _data.electrode_area() * _data.ballast_resist()) +
      (-1. + _r) * -_d_n_gamma_d_u * _v_e_th;

  return _test[_i][_qp] * (_d_numerator_d_u * _denominator - _d_denominator_d_u * _numerator) /
         (_denominator * _denominator);
}

Real
NeumannCircuitVoltage::computeQpOffDiagJacobian(unsigned int jvar)
{
  if (jvar == _ip_id)
  {
    if (_normals[_qp] * -1.0 * -_grad_u[_qp] > 0.0)
    {
      _a = 1.0;
      _b = 0.;
    }
    else
    {
      _a = 0.0;
      _b = 1.;
    }

    _ion_flux = _sgnip[_qp] * _muip[_qp] * -_grad_u[_qp] * std::exp(_ip[_qp]) -
                _Dip[_qp] * std::exp(_ip[_qp]) * _grad_ip[_qp];
    _d_ion_flux_d_ip =
        _sgnip[_qp] * _muip[_qp] * -_grad_u[_qp] * std::exp(_ip[_qp]) * _phi[_j][_qp] -
        _Dip[_qp] * (std::exp(_ip[_qp]) * _phi[_j][_qp] * _grad_ip[_qp] +
                     std::exp(_ip[_qp]) * _grad_phi[_j][_qp]);
    _n_gamma = (1. - _a) * _se_coeff[_qp] * _ion_flux * _normals[_qp] /
               (_muem[_qp] * -_grad_u[_qp] * _normals[_qp]);
    _d_n_gamma_d_ip = (1. - _a) * _se_coeff[_qp] * _d_ion_flux_d_ip * _normals[_qp] /
                      (_muem[_qp] * -_grad_u[_qp] * _normals[_qp]);
    _v_e_th =
        std::sqrt(8 * _e * 2.0 / 3 * std::exp(_mean_en[_qp] - _em[_qp]) / (M_PI * _massem[_qp])) /
        (_mu0 * _E0);
    _v_i_th = std::sqrt(8 * _kb[_qp] * _T_heavy[_qp] / (M_PI * _mass[_qp])) / (_mu0 * _E0);

    _numerator = (-2. * (1. + _r) * (_u[_qp] + _V_bat.value(_t, _q_point[_qp])) * _e /
                      (_eps * _E0 * _l0 * _l0 * _data.electrode_area() * _data.ballast_resist()) +
                  (-1. + _r) * ((-1. + (-1. + _a) * _se_coeff[_qp]) * std::exp(_ip[_qp]) * _v_i_th +
                                (std::exp(_em[_qp]) - _n_gamma) * _v_e_th));
    _denominator =
        (2. *
         ((-1. + 2. * _a) * _muem[_qp] * (std::exp(_em[_qp]) - _n_gamma) -
          (-1. + 2. * _b) * (-1. + (-1. + _a) * _se_coeff[_qp]) * _muip[_qp] * std::exp(_ip[_qp])) *
         (-1. + _r));

    _d_numerator_d_ip = (-1. + _r) * ((-1. + (-1. + _a) * _se_coeff[_qp]) * std::exp(_ip[_qp]) *
                                          _phi[_j][_qp] * _v_i_th +
                                      (-_d_n_gamma_d_ip) * _v_e_th);
    _d_denominator_d_ip = (2. *
                           ((-1. + 2. * _a) * _muem[_qp] * (-_d_n_gamma_d_ip) -
                            (-1. + 2. * _b) * (-1. + (-1. + _a) * _se_coeff[_qp]) * _muip[_qp] *
                                std::exp(_ip[_qp]) * _phi[_j][_qp]) *
                           (-1. + _r));

    return _test[_i][_qp] * (_d_numerator_d_ip * _denominator - _d_denominator_d_ip * _numerator) /
           (_denominator * _denominator);
  }

  else if (jvar == _em_id)
  {
    if (_normals[_qp] * -1.0 * -_grad_u[_qp] > 0.0)
    {
      _a = 1.0;
      _b = 0.;
    }
    else
    {
      _a = 0.0;
      _b = 1.;
    }

    _ion_flux = _sgnip[_qp] * _muip[_qp] * -_grad_u[_qp] * std::exp(_ip[_qp]) -
                _Dip[_qp] * std::exp(_ip[_qp]) * _grad_ip[_qp];
    _n_gamma = (1. - _a) * _se_coeff[_qp] * _ion_flux * _normals[_qp] /
               (_muem[_qp] * -_grad_u[_qp] * _normals[_qp]);
    _actual_mean_en = std::exp(_mean_en[_qp] - _em[_qp]);
    _d_n_gamma_d_em = -1. * (1. - _a) * _se_coeff[_qp] * _ion_flux * _normals[_qp] /
                      (std::pow(_muem[_qp] * -_grad_u[_qp] * _normals[_qp], 2.)) * -_grad_u[_qp] *
                      _normals[_qp] * _d_muem_d_actual_mean_en[_qp] * _actual_mean_en *
                      -_phi[_j][_qp];
    _v_e_th =
        std::sqrt(8 * _e * 2.0 / 3 * std::exp(_mean_en[_qp] - _em[_qp]) / (M_PI * _massem[_qp])) /
        (_mu0 * _E0);
    _d_v_e_th_d_em = 0.5 / _v_e_th * 8 * _e * 2.0 / 3 * _actual_mean_en / (M_PI * _massem[_qp]) *
                     -_phi[_j][_qp] / (_mu0 * _E0);
    _v_i_th = std::sqrt(8 * _kb[_qp] * _T_heavy[_qp] / (M_PI * _mass[_qp])) / (_mu0 * _E0);

    _numerator = (-2. * (1. + _r) * (_u[_qp] + _V_bat.value(_t, _q_point[_qp])) * _e /
                      (_eps * _E0 * _l0 * _l0 * _data.electrode_area() * _data.ballast_resist()) +
                  (-1. + _r) * ((-1. + (-1. + _a) * _se_coeff[_qp]) * std::exp(_ip[_qp]) * _v_i_th +
                                (std::exp(_em[_qp]) - _n_gamma) * _v_e_th));
    _denominator =
        (2. *
         ((-1. + 2. * _a) * _muem[_qp] * (std::exp(_em[_qp]) - _n_gamma) -
          (-1. + 2. * _b) * (-1. + (-1. + _a) * _se_coeff[_qp]) * _muip[_qp] * std::exp(_ip[_qp])) *
         (-1. + _r));

    _d_numerator_d_em =
        (-1. + _r) * ((std::exp(_em[_qp]) - _n_gamma) * _d_v_e_th_d_em +
                      (std::exp(_em[_qp]) * _phi[_j][_qp] - _d_n_gamma_d_em) * _v_e_th);
    _d_denominator_d_em =
        (2. *
         (((-1. + 2. * _a) * _d_muem_d_actual_mean_en[_qp] * _actual_mean_en * -_phi[_j][_qp] *
           (std::exp(_em[_qp]) - _n_gamma)) +
          ((-1. + 2. * _a) * _muem[_qp] * (std::exp(_em[_qp]) * _phi[_j][_qp] - _d_n_gamma_d_em))) *
         (-1. + _r));

    return _test[_i][_qp] * (_d_numerator_d_em * _denominator - _d_denominator_d_em * _numerator) /
           (_denominator * _denominator);
  }

  else if (jvar == _mean_en_id)
  {
    if (_normals[_qp] * -1.0 * -_grad_u[_qp] > 0.0)
    {
      _a = 1.0;
      _b = 0.;
    }
    else
    {
      _a = 0.0;
      _b = 1.;
    }

    _ion_flux = _sgnip[_qp] * _muip[_qp] * -_grad_u[_qp] * std::exp(_ip[_qp]) -
                _Dip[_qp] * std::exp(_ip[_qp]) * _grad_ip[_qp];
    _n_gamma = (1. - _a) * _se_coeff[_qp] * _ion_flux * _normals[_qp] /
               (_muem[_qp] * -_grad_u[_qp] * _normals[_qp]);
    _actual_mean_en = std::exp(_mean_en[_qp] - _em[_qp]);
    _d_n_gamma_d_mean_en = -1. * (1. - _a) * _se_coeff[_qp] * _ion_flux * _normals[_qp] /
                           (std::pow(_muem[_qp] * -_grad_u[_qp] * _normals[_qp], 2.)) *
                           -_grad_u[_qp] * _normals[_qp] * _d_muem_d_actual_mean_en[_qp] *
                           _actual_mean_en * _phi[_j][_qp];
    _v_e_th =
        std::sqrt(8 * _e * 2.0 / 3 * std::exp(_mean_en[_qp] - _em[_qp]) / (M_PI * _massem[_qp])) /
        (_mu0 * _E0);
    _d_v_e_th_d_mean_en = 0.5 / _v_e_th * 8 * _e * 2.0 / 3 * _actual_mean_en /
                          (M_PI * _massem[_qp]) * _phi[_j][_qp] / (_mu0 * _E0);
    _v_i_th = std::sqrt(8 * _kb[_qp] * _T_heavy[_qp] / (M_PI * _mass[_qp])) / (_mu0 * _E0);

    _numerator = (-2. * (1. + _r) * (_u[_qp] + _V_bat.value(_t, _q_point[_qp])) * _e /
                      (_eps * _E0 * _l0 * _l0 * _data.electrode_area() * _data.ballast_resist()) +
                  (-1. + _r) * ((-1. + (-1. + _a) * _se_coeff[_qp]) * std::exp(_ip[_qp]) * _v_i_th +
                                (std::exp(_em[_qp]) - _n_gamma) * _v_e_th));
    _denominator =
        (2. *
         ((-1. + 2. * _a) * _muem[_qp] * (std::exp(_em[_qp]) - _n_gamma) -
          (-1. + 2. * _b) * (-1. + (-1. + _a) * _se_coeff[_qp]) * _muip[_qp] * std::exp(_ip[_qp])) *
         (-1. + _r));

    _d_numerator_d_mean_en = (-1. + _r) * ((std::exp(_em[_qp]) - _n_gamma) * _d_v_e_th_d_mean_en +
                                           (-_d_n_gamma_d_mean_en) * _v_e_th);
    _d_denominator_d_mean_en =
        (2. *
         (((-1. + 2. * _a) * _d_muem_d_actual_mean_en[_qp] * _actual_mean_en * _phi[_j][_qp] *
           (std::exp(_em[_qp]) - _n_gamma)) +
          ((-1. + 2. * _a) * _muem[_qp] * (-_d_n_gamma_d_mean_en))) *
         (-1. + _r));

    return _test[_i][_qp] *
           (_d_numerator_d_mean_en * _denominator - _d_denominator_d_mean_en * _numerator) /
           (_denominator * _denominator);
  }

  else
    return 0.0;
}
