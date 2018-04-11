dom0Scale=1.0
dom1Scale=1.0
dom2Scale=1.0

[GlobalParams]
  offset = 20
  # offset = 0
  potential_units = kV
  use_moles = true
  # potential_units = V
[]

[Mesh]
  type = FileMesh
  file = 'dbd_3region.msh'
[]

[MeshModifiers]
  [./interface01]
    type = SideSetsBetweenSubdomains
    master_block = '0'
    paired_block = '1'
    new_boundary = 'master01_interface'
  [../]
  [./interface02]
    type = SideSetsBetweenSubdomains
    master_block = '0'
    paired_block = '2'
    new_boundary = 'master02_interface'
  [../]
  [./interface_again]
    type = SideSetsBetweenSubdomains
    master_block = '1'
    paired_block = '0'
    new_boundary = 'master1_interface'
  [../]
  [./interface_again_again]
    type = SideSetsBetweenSubdomains
    master_block = '2'
    paired_block = '0'
    new_boundary = 'master2_interface'
  [../]
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
  # kernel_coverage_check = false
[]

[Preconditioning]
  [./smp]
    type = SMP
    full = true
    ksp_norm = none
  [../]
[]

[Executioner]
  type = Transient
  end_time = 1e-4
  petsc_options = '-snes_converged_reason -snes_linesearch_monitor'
  solve_type = NEWTON
  petsc_options_iname = '-pc_type -pc_factor_shift_type -pc_factor_shift_amount -ksp_type -snes_linesearch_minlambda'
  petsc_options_value = 'lu NONZERO 1.e-10 preonly 1e-3'
  nl_rel_tol = 1e-4
  nl_abs_tol = 7.6e-5
  dtmin = 1e-12
  l_max_its = 20

  [./TimeStepper]
    type = IterationAdaptiveDT
    cutback_factor = 0.4
    dt = 1e-11
    growth_factor = 1.2
    optimal_iterations = 15
  [../]
[]

[Outputs]
  print_perf_log = true
  #print_linear_residuals = false
  [./out]
    type = Exodus
  [../]
[]

[UserObjects]
  [./data_provider]
    type = ProvideMobility
    #electrode_area = 5.02e-7
    #electrode_area = 3.02e-5 # Formerly 3.14e-6
    electrode_area = 0.007854
    #ballast_resist = 1e6
    ballast_resist = 1e4
    e = 1.6e-19
    # electrode_area = 1.1
    # ballast_resist = 1.1
    # e = 1.1
  [../]
[]


[Kernels]
  [./em_time_deriv]
    type = ElectronTimeDerivative
    variable = em
    block = 0
  [../]
  [./em_advection]
    type = EFieldAdvectionElectrons
    variable = em
    potential = potential_gas
    mean_en = mean_en
    block = 0
    position_units = ${dom0Scale}
  [../]
  [./em_diffusion]
    type = CoeffDiffusionElectrons
    variable = em
    mean_en = mean_en
    block = 0
    position_units = ${dom0Scale}
  [../]
  [./em_ionization]
    type = ElectronsFromIonization
    variable = em
    potential = potential_gas
    mean_en = mean_en
    em = em
    block = 0
    position_units = ${dom0Scale}
  [../]
  [./em_log_stabilization]
    type = LogStabilizationMoles
    variable = em
    block = 0
  [../]

  [./potential_diffusion_dom0]
    type = CoeffDiffusionLin
    variable = potential_gas
    block = 0
    position_units = ${dom0Scale}
  [../]
  [./potential_diffusion_dom1]
    type = CoeffDiffusionLin
    variable = potential_d1
    block = 1
    position_units = ${dom1Scale}
  [../]
  [./potential_diffusion_dom2]
    type = CoeffDiffusionLin
    variable = potential_d2
    block = 2
    position_units = ${dom2Scale}
  [../]

  [./Arp_charge_source]
    type = ChargeSourceMoles_KV
    variable = potential_gas
    charged = Arp
    block = 0
  [../]
  [./em_charge_source]
    type = ChargeSourceMoles_KV
    variable = potential_gas
    charged = em
    block = 0
  [../]

  [./Arp_time_deriv]
    type = ElectronTimeDerivative
    variable = Arp
    block = 0
  [../]
  [./Arp_advection]
    type = EFieldAdvection
    variable = Arp
    potential = potential_gas
    position_units = ${dom0Scale}
    block = 0
  [../]
  [./Arp_diffusion]
    type = CoeffDiffusion
    variable = Arp
    block = 0
    position_units = ${dom0Scale}
  [../]
  [./Arp_ionization]
    type = IonsFromIonization
    variable = Arp
    potential = potential_gas
    em = em
    mean_en = mean_en
    block = 0
    position_units = ${dom0Scale}
  [../]
  [./Arp_log_stabilization]
    type = LogStabilizationMoles
    variable = Arp
    block = 0
  [../]

  [./mean_en_time_deriv]
    type = ElectronTimeDerivative
    variable = mean_en
    block = 0
  [../]
  [./mean_en_advection]
    type = EFieldAdvectionEnergy
    variable = mean_en
    potential = potential_gas
    em = em
    block = 0
    position_units = ${dom0Scale}
  [../]
  [./mean_en_diffusion]
    type = CoeffDiffusionEnergy
    variable = mean_en
    em = em
    block = 0
    position_units = ${dom0Scale}
  [../]
  [./mean_en_joule_heating]
    type = JouleHeating
    variable = mean_en
    potential = potential_gas
    em = em
    block = 0
    position_units = ${dom0Scale}
  [../]
  [./mean_en_ionization]
    type = ElectronEnergyLossFromIonization
    variable = mean_en
    potential = potential_gas
    em = em
    block = 0
    position_units = ${dom0Scale}
  [../]
  [./mean_en_elastic]
    type = ElectronEnergyLossFromElastic
    variable = mean_en
    potential = potential_gas
    em = em
    block = 0
    position_units = ${dom0Scale}
  [../]
  [./mean_en_excitation]
    type = ElectronEnergyLossFromExcitation
    variable = mean_en
    potential = potential_gas
    em = em
    block = 0
    position_units = ${dom0Scale}
  [../]
  [./mean_en_log_stabilization]
    type = LogStabilizationMoles
    variable = mean_en
    block = 0
    offset = 15
  [../]

[]


[Variables]
  [./potential_d1]
    block = 1
  [../]
  [./potential_d2]
    block = 2
  [../]
  [./potential_gas]
    block = 0
  [../]

  [./em]
    block = 0
  [../]

  [./Arp]
    block = 0
  [../]

  [./mean_en]
    block = 0
  [../]
[]


[AuxVariables]
  [./e_temp]
    order = CONSTANT
    family = MONOMIAL
    block = 0
  [../]

  [./x]
    order = CONSTANT
    family = MONOMIAL
  [../]

  [./x_node]
  [../]

  [./rho]
    order = CONSTANT
    family = MONOMIAL
    block = 0
  [../]
  [./em_lin]
    order = CONSTANT
    family = MONOMIAL
    block = 0
  [../]
  [./Arp_lin]
    order = CONSTANT
    family = MONOMIAL
    block = 0
  [../]
  [./Efield]
    order = CONSTANT
    family = MONOMIAL
  [../]
  [./Current_em]
    order = CONSTANT
    family = MONOMIAL
    block = 0
  [../]
  [./Current_Arp]
    order = CONSTANT
    family = MONOMIAL
    block = 0
  [../]

  [./tot_gas_current]
    order = CONSTANT
    family = MONOMIAL
    block = 0
  [../]
[]

[AuxKernels]
  [./e_temp]
    type = ElectronTemperature
    variable = e_temp
    electron_density = em
    mean_en = mean_en
    block = 0
  [../]
  [./x_g]
    type = Position
    variable = x
    position_units = ${dom0Scale}
    block = 0
  [../]
  [./x_d1]
    type = Position
    variable = x
    position_units = ${dom1Scale}
    block = 1
  [../]
  [./x_d2]
    type = Position
    variable = x
    position_units = ${dom2Scale}
    block = 2
  [../]

  [./x_ng]
    type = Position
    variable = x_node
    position_units = ${dom0Scale}
    block = 0
  [../]
  [./x_nd1]
    type = Position
    variable = x_node
    position_units = ${dom1Scale}
    block = 1
  [../]
  [./x_nd2]
    type = Position
    variable = x_node
    position_units = ${dom2Scale}
    block = 2
  [../]

  [./rho]
    type = ParsedAux
    variable = rho
    args = 'em_lin Arp_lin'
    function = 'Arp_lin - em_lin'
    execute_on = 'timestep_end'
    block = 0
  [../]

  [./tot_gas_current]
    type = ParsedAux
    variable = tot_gas_current
    args = 'Current_em Current_Arp'
    function = 'Current_em + Current_Arp'
    execute_on = 'timestep_end'
    block = 0
  [../]

  [./em_lin]
    type = DensityMoles
    convert_moles = true
    variable = em_lin
    density_log = em
    block = 0
  [../]
  [./Arp_lin]
    type = DensityMoles
    convert_moles = true
    variable = Arp_lin
    density_log = Arp
    block = 0
  [../]
  [./Efield_g]
    type = Efield
    component = 0
    potential = potential_gas
    variable = Efield
    position_units = ${dom0Scale}
    block = 0
  [../]
  [./Efield_d1]
    type = Efield
    component = 0
    potential = potential_d1
    variable = Efield
    position_units = ${dom1Scale}
    block = 1
  [../]
  [./Efield_d2]
    type = Efield
    component = 0
    potential = potential_d2
    variable = Efield
    position_units = ${dom2Scale}
    block = 2
  [../]
  [./Current_em]
    type = Current
    potential = potential_gas
    density_log = em
    variable = Current_em
    art_diff = false
    block = 0
    position_units = ${dom0Scale}
  [../]
  [./Current_Arp]
    type = Current
    potential = potential_gas
    density_log = Arp
    variable = Current_Arp
    art_diff = false
    block = 0
    position_units = ${dom0Scale}
  [../]

[]


[InterfaceKernels]
  [./dielectric1_interface]
    type = FluxInterface
    neighbor_var = potential_d1
    variable = potential_gas
    boundary = 'master01_interface'
    region_name = 'gas'
    neighbor_region_name = 'd1'
    position_units = ${dom0Scale}
    neighbor_position_units = ${dom1Scale}
  [../]

  [./dielectric2_interface]
    type = FluxInterface
    neighbor_var = potential_d2
    variable = potential_gas
    boundary = 'master02_interface'
    region_name = 'gas'
    neighbor_region_name = 'd2'
    position_units = ${dom0Scale}
    neighbor_position_units = ${dom2Scale}
  [../]
[]


[BCs]
  [./potential_left]
    type = FunctionDirichletBC
    variable = potential_d2
    boundary = 'left'
    function = potential_bc_dirichlet
  [../]
  [./potential_dirichlet_right]
    type = DirichletBC
    variable = potential_d1
    boundary = 'right'
    value = 0
  [../]

  ### APPLY BCS ON DIELECTRIC-GAS BOUNDARY
  [./dielectric1_potential]
    type = MatchedValueBC
    variable = potential_d1
    v = potential_gas
    boundary = 'master1_interface'
  [../]
  [./dielectric2_potential]
    type = MatchedValueBC
    variable = potential_d2
    v = potential_gas
    boundary = 'master2_interface'
  [../]
  [./em_physical_right]
    type = HagelaarElectronBC
    variable = em
    boundary = 'master01_interface'
    potential = potential_gas
    ip = Arp
    mean_en = mean_en
    #r = 0.0
    r = 0
    position_units = ${dom0Scale}
  [../]
  [./Arp_physical_right_diffusion]
    type = HagelaarIonDiffusionBC
    variable = Arp
    boundary = 'master01_interface'
    r = 0
    position_units = ${dom0Scale}
  [../]
  [./Arp_physical_right_advection]
    type = HagelaarIonAdvectionBC
    variable = Arp
    boundary = 'master01_interface'
    potential = potential_gas
    r = 0
    position_units = ${dom0Scale}
  [../]
  [./mean_en_physical_right]
    type = HagelaarEnergyBC
    variable = mean_en
    boundary = 'master01_interface'
    potential = potential_gas
    em = em
    ip = Arp
    r = 0.0
    position_units = ${dom0Scale}
  [../]
  [./em_physical_left]
    type = HagelaarElectronBC
    variable = em
    boundary = 'master02_interface'
    potential = potential_gas
    ip = Arp
    mean_en = mean_en
    #r = 0
    r = 0
    position_units = ${dom0Scale}
  [../]
  [./Arp_physical_left_diffusion]
    type = HagelaarIonDiffusionBC
    variable = Arp
    boundary = 'master02_interface'
    r = 0
    position_units = ${dom0Scale}
  [../]
  [./Arp_physical_left_advection]
    type = HagelaarIonAdvectionBC
    variable = Arp
    boundary = 'master02_interface'
    potential = potential_gas
    r = 0
    position_units = ${dom0Scale}
  [../]
  [./mean_en_physical_left]
    type = HagelaarEnergyBC
    variable = mean_en
    boundary = 'master02_interface'
    potential = potential_gas
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
    value = -21

  [../]
  [./Arp_ic]
    type = ConstantIC
    variable = Arp
    value = -21

  [../]
  [./mean_en_ic]
    type = ConstantIC
    variable = mean_en
    value = -20

  [../]

  [./potential_gas_ic]
    type = FunctionIC
    variable = potential_gas
    function = potential_ic_func
  [../]
  [./potential_d1_ic]
    type = FunctionIC
    variable = potential_d1
    function = potential_ic_func
  [../]
  [./potential_d2_ic]
    type = FunctionIC
    variable = potential_d2
    function = potential_ic_func
  [../]
[]

[Functions]
  [./potential_bc_dirichlet]
    type = ParsedFunction
    value = '-0.75*sin(314159.26*t)'
    # RF frequency is 50kHz
  [../]
  [./potential_bc_func]
    type = ParsedFunction
    value = '0.01'
  [../]
  [./potential_ic_func]
    type = ParsedFunction
    value = '0.0'
  [../]
[]

[Materials]
  [./gas_block]
    type = Gas
    #type = HeavySpeciesMaterial
    interp_trans_coeffs = true
    interp_elastic_coeff = true
    ramp_trans_coeffs = false
    em = em
    potential = potential_gas
    ip = Arp
    mean_en = mean_en
    user_se_coeff = 0.0
    property_tables_file = td_argon_mean_en.txt
    block = 0
 [../]
 [./gas_constant]
    type = GenericConstantMaterial
    prop_names = 'diffpotential_gas'
    prop_values = '8.854e-12'
    block = 0
 [../]
 [./dielectric1]
    type = GenericConstantMaterial
    prop_names = 'diffpotential_d1'
    prop_values = '8.854e-11'
    block = 1
 [../]
 [./dielectric2]
    type = GenericConstantMaterial
    prop_names = 'diffpotential_d2'
    prop_values = '8.854e-11'
    block = 2
 [../]
 #[./sigma_mat2]
  #  type = SigmaMat
  #  n = em
  #  potential = potential_gas
  #  boundary = 'master02_interface'
 #[../]

[]
