[GlobalParams]
[]

[Mesh]
  type = GeneratedMesh
  dim = 1
  nx = 1000
  xmin = 0
  xmax = 1e-3
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
  end_time = 1e-1
  solve_type = NEWTON
  petsc_options = '-snes_converged_reason -pc_svd_monitor'
  petsc_options_iname = '-pc_type -pc_factor_shift_type -pc_factor_shift_amount -ksp_type' # -pc_factor_mat_solver_package'
  petsc_options_value = 'svd NONZERO 1.e-10 preonly' # mumps'
 # nl_rel_tol = 1e-10
 # l_tol = 1e-3
 # trans_ss_check = true
 # ss_check_tol = 1e-7
 # nl_abs_tol = 1e-3
  l_max_its = 10
 nl_max_its = 50
  dtmin = 1e-12
  [./TimeStepper]
    type = IterationAdaptiveDT
    cutback_factor = 0.4
    dt = 1e-9
    growth_factor = 1.2
   optimal_iterations = 50
  [../]
[]

[Outputs]
  print_perf_log = true
  [./out]
    type = Exodus
    # output_material_properties = true
    # show_material_properties = 'ElectronTotalFlux ElectronAdvectiveFlux ElectronDiffusiveFlux IonTotalFlux IonAdvectiveFlux IonDiffusiveFlux EField'
    # show_material_properties = 'EField'
  [../]
[]

[Debug]
  show_var_residual_norms = true
[]

[UserObjects]
  [./data_provider]
    type = ProvideMobility
    # electrode_area = 3.14e-6 # Formerly 3.14e-6
    electrode_area = 5.02e-7 # Formerly 3.14e-6
    ballast_resist = 8.1e3
    # ballast_resist = 1e6
  [../]
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
    type = ElectronsFromIonizationLFA
    variable = em
    potential = potential
  [../]
  [./em_log_stabilization]
    type = LogStabilization
    variable = em
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
    type = IonsFromIonizationLFA
    variable = Arp
    potential = potential
    em = em
  [../]
  [./Arp_log_stabilization]
    type = LogStabilization
    variable = Arp
  [../]
  # [./Arp_advection_stabilization]
  #   type = EFieldArtDiff
  #   variable = Arp
  #   potential = potential
  # [../]

  [./potential_diffusion]
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
[]

[Variables]
  [./potential]
    scaling = 1e-5
  [../]
  [./em]
    scaling = 1e-18
  [../]
  [./Arp]
    scaling = 1e-18
  [../]
[]

[AuxVariables]
  [./em_lin]
  [../]
  [./Arp_lin]
  [../]
[]

[AuxKernels]
  [./em_lin]
    type = Density
    variable = em_lin
    density_log = em
  [../]
  [./Arp_lin]
    type = Density
    variable = Arp_lin
    density_log = Arp
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
  [../]
  [./potential_dirichlet_right]
    type = DirichletBC
    variable = potential
    boundary = right
    value = 0
  [../]
  # [./potential_dirichlet_left]
  #   type = DirichletBC
  #   variable = potential
  #   boundary = left
  #   value = -1.25e3
  # [../]
  [./em_physical]
    type = DCElectronBC
    variable = em
    boundary = 'left right'
    potential = potential
    ip = Arp
    # mean_en = mean_en
  [../]
  [./Arp_physical]
    type = DCIonBC
    variable = Arp
    boundary = 'left right'
    potential = potential
  [../]
[]

[ICs]
  [./em_ic]
    type = ConstantIC
    variable = em
    value = 29.934
  [../]
  [./Arp_ic]
    type = ConstantIC
    variable = Arp
    value = 29.934
  [../]
  # [./potential_ic]
  #   type = FunctionIC
  #   variable = potential
  #   function = potential_ic_func
  # [../]
  [./potential_ic]
    type = ConstantIC
    variable = potential
    value = 0
  [../]
[]

[Functions]
  [./potential_bc_func]
    type = ParsedFunction
    value = '1.25e3*tanh(1e6*t)'
  [../]
  [./potential_ic_func]
    type = ParsedFunction
    value = -1.25e3*(.001-x)
  [../]
[]

[Materials]
  [./argon_block]
    interp_trans_coeffs = false
    interp_elastic_coeff = true
    block = 0
    type = ArgonConstTD
    em = em
    potential = potential
    # mean_en = mean_en
    ip = Arp
 [../]
 #  [./argon_boundary]
 #    interp_trans_coeffs = false
 #    interp_elastic_coeff = false
 #    boundary = 'left right'
 #    type = Water
 #    em = em
 #    potential = potential
 #    mean_en = mean_en
 #    ip = Arp
 # [../]
[]