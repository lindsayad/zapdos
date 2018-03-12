dom0Scale = 1

[GlobalParams]
  offset = 20
  characteristic_mobility = '1e-2'
  characteristic_efield = '1e7'
  characteristic_length = '1e-6'
[]

[Mesh]
  type = FileMesh
  file = 'dimensionless-plasma.msh'
[]

[MeshModifiers]
  [./left]
    type = SideSetsFromNormals
    normals = '-1 0 0'
    new_boundary = 'left'
  [../]
  [./right]
    type = SideSetsFromNormals
    normals = '1 0 0'
    new_boundary = 'right'
  [../]
[]

[Problem]
  type = FEProblem
[]

[Preconditioning]
  [./smp]
    type = FDP
    full = true
  [../]
[]

[Executioner]
  type = Transient
  end_time = 1e10
  petsc_options = '-snes_converged_reason -ksp_converged_reason -snes_linesearch_monitor -ksp_monitor_true_residual -ksp_monitor_singular_value'
  solve_type = PJFNK
  petsc_options_iname = '-pc_type -snes_linesearch_minlambda -pc_factor_shift_type'
  petsc_options_value = 'lu       1e-3                       NONZERO'
  nl_rel_tol = 1e-4
  nl_abs_tol = 1e-12
  dtmin = 1e-1
  l_max_its = 100
  line_search = 'bt'
  [./TimeStepper]
    type = IterationAdaptiveDT
    cutback_factor = 0.4
    dt = 1
    growth_factor = 1.2
    optimal_iterations = 15
  [../]
[]

[Outputs]
  checkpoint = true
  print_perf_log = true
  print_linear_residuals = false
  [./out]
    type = Exodus
  [../]
[]

[Debug]
  show_var_residual_norms = true
[]

[UserObjects]
  [./data_provider]
    type = ProvideMobility
    electrode_area = 5.02e5 # This is also dimensionless
    ballast_resist = .0016 # This is dimensionless
    e = 1.6e-19
  [../]
[]

# [AuxVariables]
#   [./e_temp]
#   [../]
#   [./em_lin]
#   [../]
#   [./Arp_lin]
#   [../]
# []

# [AuxKernels]
#   [./em_lin]
#     type = DensityFromDimensionless
#     convert_moles = true
#     variable = em_lin
#     density_log = em
#   [../]
#   [./Arp_lin]
#     type = DensityFromDimensionless
#     convert_moles = true
#     variable = Arp_lin
#     density_log = Arp
#   [../]
#   [./e_temp]
#     type = ElectronTemperature
#     variable = e_temp
#     electron_density = em
#     mean_en = mean_en
#   [../]
# []

[Kernels]
  [./em_time_deriv]
    type = ElectronTimeDerivative
    variable = em
  [../]
  [./em_advection]
    type = EFieldAdvectionElectrons
    variable = em
    potential = potential
    mean_en = mean_en
    position_units = ${dom0Scale}
  [../]
  [./em_diffusion]
    type = CoeffDiffusionElectrons
    variable = em
    mean_en = mean_en
    position_units = ${dom0Scale}
  [../]
  [./em_ionization]
    type = ElectronsFromIonization
    variable = em
    potential = potential
    mean_en = mean_en
    em = em
    position_units = ${dom0Scale}
  [../]
  [./em_log_stabilization]
    type = LogStabilizationMoles
    variable = em
  [../]

  [./potential_diffusion_dom1]
    type = CoeffDiffusionLin
    variable = potential
    position_units = ${dom0Scale}
  [../]
  [./Arp_charge_source]
    type = ChargeSource
    variable = potential
    charged = Arp
  [../]
  [./em_charge_source]
    type = ChargeSource
    variable = potential
    charged = em
  [../]

  [./Arp_time_deriv]
    type = ElectronTimeDerivative
    variable = Arp
  [../]
  [./Arp_advection]
    type = EFieldAdvection
    variable = Arp
    potential = potential
    position_units = ${dom0Scale}
  [../]
  [./Arp_diffusion]
    type = CoeffDiffusion
    variable = Arp
    position_units = ${dom0Scale}
  [../]
  [./Arp_ionization]
    type = IonsFromIonization
    variable = Arp
    potential = potential
    em = em
    mean_en = mean_en
    position_units = ${dom0Scale}
  [../]
  [./Arp_log_stabilization]
    type = LogStabilizationMoles
    variable = Arp
  [../]

  [./mean_en_time_deriv]
    type = ElectronTimeDerivative
    variable = mean_en
  [../]
  [./mean_en_advection]
    type = EFieldAdvectionEnergy
    variable = mean_en
    potential = potential
    em = em
    position_units = ${dom0Scale}
  [../]
  [./mean_en_diffusion]
    type = CoeffDiffusionEnergy
    variable = mean_en
    em = em
    position_units = ${dom0Scale}
  [../]
  [./mean_en_joule_heating]
    type = JouleHeating
    variable = mean_en
    potential = potential
    em = em
    position_units = ${dom0Scale}
  [../]
  [./mean_en_ionization]
    type = ElectronEnergyLossFromIonization
    variable = mean_en
    potential = potential
    em = em
    position_units = ${dom0Scale}
  [../]
  [./mean_en_elastic]
    type = ElectronEnergyLossFromElastic
    variable = mean_en
    potential = potential
    em = em
    position_units = ${dom0Scale}
  [../]
  [./mean_en_excitation]
    type = ElectronEnergyLossFromExcitation
    variable = mean_en
    potential = potential
    em = em
    position_units = ${dom0Scale}
  [../]
  [./mean_en_log_stabilization]
    type = LogStabilizationMoles
    variable = mean_en
    offset = 15
  [../]
[]

[Variables]
  [./potential]
  [../]
  [./em]
  [../]
  [./Arp]
  [../]
  [./mean_en]
  [../]
[]

[BCs]
  [./potential_left]
    type = NeumannCircuitVoltage
    variable = potential
    boundary = left
    function = potential_bc_func
    ip = Arp
    data_provider = data_provider
    em = em
    mean_en = mean_en
    r = 0
  [../]
  # [./potential_dirichlet_left]
  #   type = DirichletBC
  #   variable = potential
  #   boundary = left
  #   value = -125
  # [../]
  [./potential_dirichlet_right]
    type = DirichletBC
    variable = potential
    boundary = right
    value = 0
  [../]
  [./em_physical_right]
    type = HagelaarElectronBC
    variable = em
    boundary = 'right'
    potential = potential
    mean_en = mean_en
    r = 0.99
    position_units = ${dom0Scale}
  [../]
  [./Arp_physical_right_diffusion]
    type = HagelaarIonDiffusionBC
    variable = Arp
    boundary = 'right'
    r = 0
    position_units = ${dom0Scale}
  [../]
  [./Arp_physical_right_advection]
    type = HagelaarIonAdvectionBC
    variable = Arp
    boundary = 'right'
    potential = potential
    r = 0
    position_units = ${dom0Scale}
  [../]
  [./mean_en_physical_right]
    type = HagelaarEnergyBC
    variable = mean_en
    boundary = 'right'
    potential = potential
    em = em
    ip = Arp
    r = 0.99
    position_units = ${dom0Scale}
  [../]
  [./em_physical_left]
    type = HagelaarElectronBC
    variable = em
    boundary = 'left'
    potential = potential
    mean_en = mean_en
    r = 0
    position_units = ${dom0Scale}
  [../]
  [./sec_electrons_left]
    type = SecondaryElectronBC
    variable = em
    boundary = 'left'
    potential = potential
    ip = Arp
    mean_en = mean_en
    r = 0
    position_units = ${dom0Scale}
  [../]
  [./Arp_physical_left_diffusion]
    type = HagelaarIonDiffusionBC
    variable = Arp
    boundary = 'left'
    r = 0
    position_units = ${dom0Scale}
  [../]
  [./Arp_physical_left_advection]
    type = HagelaarIonAdvectionBC
    variable = Arp
    boundary = 'left'
    potential = potential
    r = 0
    position_units = ${dom0Scale}
  [../]
  [./mean_en_physical_left]
    type = HagelaarEnergyBC
    variable = mean_en
    boundary = 'left'
    potential = potential
    em = em
    ip = Arp
    r = 0
    position_units = ${dom0Scale}
  [../]
[]

[ICs]
  [./em_ic]
    type = ConstantIC
    variable = em
    value = -14
  [../]
  [./Arp_ic]
    type = ConstantIC
    variable = Arp
    value = -14
  [../]
  [./mean_en_ic]
    type = ConstantIC
    variable = mean_en
    value = -13
  [../]
  # [./potential_ic]
  #   type = RandomIC
  #   variable = potential
  #   min = -125
  #   max = 0
  # [../]
  [./potential_ic]
    type = FunctionIC
    variable = potential
    function = potential_ic_func
  [../]
[]

[Functions]
  [./potential_bc_func]
    type = ParsedFunction
    # value = '1.25*tanh(1e6*t)'
    value = 125
  [../]
  [./potential_ic_func]
    type = ParsedFunction
    value = '-125. * (1. - x / 1000.)'
  [../]
[]

[Materials]
  [./gas_block]
    type = DimensionlessGas
    em = em
    potential = potential
    ip = Arp
    mean_en = mean_en
    user_se_coeff = .05
    property_tables_file = td_argon_mean_en.txt
 [../]
[]
