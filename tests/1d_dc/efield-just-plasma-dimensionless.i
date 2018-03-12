resist = .0016
area = 5.02e5

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
  petsc_options_iname = '-pc_type -snes_linesearch_minlambda'
  petsc_options_value = 'lu       1e-3'
  nl_rel_tol = 1e-4
  nl_abs_tol = 1e-9
  dtmin = 1e-3
  l_max_its = 100
  nl_max_its = 10
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
    # ballast_resist =  ${resist} # fails with sub
    # electrode_area = ${area} # fails with sub
    ballast_resist = .0016 # works
    electrode_area = 5.02e5 # works
    e = 1.6e-19
  [../]
[]

[AuxVariables]
  # [./e_temp]
  # [../]
  [./em_lin]
  [../]
  [./Arp_lin]
  [../]
[]

[AuxKernels]
  [./em_lin]
    type = DensityFromDimensionless
    convert_moles = true
    variable = em_lin
    density_log = em
  [../]
  [./Arp_lin]
    type = DensityFromDimensionless
    convert_moles = true
    variable = Arp_lin
    density_log = Arp
  [../]
  # [./e_temp]
  #   type = ElectronTemperature
  #   variable = e_temp
  #   electron_density = em
  #   mean_en = mean_en
  # [../]
[]

[Kernels]
  [./em_time_deriv]
    type = ElectronTimeDerivative
    variable = em
  [../]
  [./em_advection]
    type = EFieldAdvection
    variable = em
    potential = potential
  [../]
  [./em_diffusion]
    type = CoeffDiffusion
    variable = em
  [../]
  [./em_ionization]
    type = IonizationSourceEField
    variable = em
    potential = potential
    em = em
  [../]
  [./em_log_stabilization]
    type = LogStabilizationMoles
    variable = em
  [../]

  [./potential_diffusion_dom1]
    type = CoeffDiffusionLin
    variable = potential
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
  [../]
  [./Arp_diffusion]
    type = CoeffDiffusion
    variable = Arp
  [../]
  [./Arp_ionization]
    type = IonizationSourceEField
    variable = Arp
    potential = potential
    em = em
  [../]
  [./Arp_log_stabilization]
    type = LogStabilizationMoles
    variable = Arp
  [../]
[]

[Variables]
  [./potential]
  [../]
  [./em]
  [../]
  [./Arp]
  [../]
[]

[BCs]
  [./potential_left]
    type = CircuitDirichletPotential
    current = flux
    surface_potential = potential_bc_func
    surface = "cathode"
    resist = ${resist}
    A = ${area}
    boundary = 'left'
    variable = potential
  [../]
  # [./potential_left]
  #   type = NeumannCircuitVoltage
  #   variable = potential
  #   boundary = left
  #   function = potential_bc_func
  #   ip = Arp
  #   data_provider = data_provider
  #   em = em
  #   r = 0
  # [../]
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
  [./em_physical]
    type = HagelaarElectronBC
    variable = em
    boundary = 'left right'
    potential = potential
    ip = Arp
    r = 0
  [../]
  [./Arp_physical_diffusion]
    type = HagelaarIonDiffusionBC
    variable = Arp
    boundary = 'left right'
    r = 0
  [../]
  [./Arp_physical_advection]
    type = HagelaarIonAdvectionBC
    variable = Arp
    boundary = 'left right'
    potential = potential
    r = 0
  [../]
  [./sec_electrons_left]
    type = SecondaryElectronBC
    variable = em
    boundary = 'left'
    potential = potential
    ip = Arp
    r = 0
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
    value = -125
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
    user_se_coeff = .05
    use_efield = true
    property_tables_file = td_argon_efield.txt
 [../]
[]

[Postprocessors]
  [./flux]
    type = SideTotFluxIntegral
    potential = potential
    ip = Arp
    em = em
    boundary = 'left'
    execute_on = 'linear nonlinear'
  [../]
[]
