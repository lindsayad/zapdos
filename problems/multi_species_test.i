dom0Scale=1e-3
#dom1Scale=1e-7
# dom0Scale=1.1
# dom1Scale=1.1

[GlobalParams]
  offset = 20
  # offset = 0
  potential_units = kV
  use_moles = true
  # potential_units = V
[]

[Mesh]
  # type = GeneratedMesh
  # nx = 2
  # xmax = 1.1
  # dim = 1
  type = FileMesh
  file = 'tempMesh.msh'
[]

[MeshModifiers]
  [./interface]
    type = SideSetsBetweenSubdomains
    master_block = '0'
    paired_block = '1'
    new_boundary = 'master0_interface'
    # depends_on = 'box'
  [../]
  [./interface_again]
    type = SideSetsBetweenSubdomains
    master_block = '1'
    paired_block = '0'
    new_boundary = 'master1_interface'
    # depends_on = 'box'
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
  # [./box]
  #   type = SubdomainBoundingBox
  #   bottom_left = '0.55 0 0'
  #   top_right = '1.1 1. 0'
  #   block_id = 1
  # [../]
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
  end_time = 1e-1
  # end_time = 10
  petsc_options = '-snes_converged_reason -snes_linesearch_monitor'
  # petsc_options = '-snes_test_display'
  solve_type = NEWTON
  petsc_options_iname = '-pc_type -pc_factor_shift_type -pc_factor_shift_amount -ksp_type -snes_linesearch_minlambda'
  petsc_options_value = 'lu NONZERO 1.e-10 preonly 1e-3'
  # petsc_options_iname = '-snes_type'
  # petsc_options_value = 'test'
 nl_rel_tol = 1e-4
 nl_abs_tol = 7.6e-5
  dtmin = 1e-12
  [./TimeStepper]
    type = IterationAdaptiveDT
    cutback_factor = 0.4
    dt = 1e-9
    # dt = 1.1
    growth_factor = 1.2
   optimal_iterations = 15
  [../]
[]

[Outputs]
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
    electrode_area = 5.02e-7 # Formerly 3.14e-6
    ballast_resist = 1e6
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
    potential = potential
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
    potential = potential
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

  [./potential_diffusion_dom1]
    type = CoeffDiffusionLin
    variable = potential
    block = 0
    position_units = ${dom0Scale}
  [../]
  [./Arp_charge_source]
    type = ChargeSourceMoles_KV
    variable = potential
    charged = Arp
    block = 0
  [../]
  [./em_charge_source]
    type = ChargeSourceMoles_KV
    variable = potential
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
    potential = potential
    position_units = ${dom0Scale}
    block = 0
  [../]

  [./Ar4s_advection]
    type = EFieldAdvection
    variable = Ar4s
    potential = potential
    position_units = ${dom0Scale}
    block = 0
  [../]

  [./Ar4s_excitation]
    type = ElectronImpactReaction
    variable = Ar4s
    potential = potential
    em = em
    mean_en = mean_en
    block = 0
    position_units = ${dom0Scale}
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
    potential = potential
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

  [./Ar4s_time_deriv]
    type = ElectronTimeDerivative
    variable = Ar4s
    block = 0
  [../]

  [./Ar4s_diffusion]
    type = CoeffDiffusion
    variable = Ar4s
    block = 0
    position_units = ${dom0Scale}
  [../]

  [./Ar4s_log_stabilization]
    type = LogStabilizationMoles
    variable = Ar4s
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
    potential = potential
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
    potential = potential
    em = em
    block = 0
    position_units = ${dom0Scale}
  [../]
  [./mean_en_ionization]
    type = ElectronEnergyLossFromIonization
    variable = mean_en
    potential = potential
    em = em
    block = 0
    position_units = ${dom0Scale}
  [../]
  [./mean_en_elastic]
    type = ElectronEnergyLossFromElastic
    variable = mean_en
    potential = potential
    em = em
    block = 0
    position_units = ${dom0Scale}
  [../]
  [./mean_en_excitation]
    type = ElectronEnergyLossFromExcitation
    variable = mean_en
    potential = potential
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
  [./potential]
  [../]
  [./em]
    block = 0
  [../]

  [./Arp]
    block = 0
  [../]

  [./Ar4s]
    block = 0
  [../]

  [./mean_en]
    block = 0
    # scaling = 1e-1
  [../]
[]

[AuxVariables]
  [./x]
    order = CONSTANT
    family = MONOMIAL
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
  [./Ar4s_lin]
    order = CONSTANT
    family = MONOMIAL
    block = 0
  [../]
[]

[AuxKernels]
  [./x_g]
    type = Position
    variable = x
    position_units = ${dom0Scale}
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
  [./Ar4s_lin]
    type = DensityMoles
    convert_moles = true
    variable = Ar4s_lin
    density_log = Ar4s
    block = 0
  [../]
[]

[BCs]
  [./potential_left]
    type = NeumannCircuitVoltageMoles_KV
    variable = potential
    boundary = left
    function = potential_bc_func
    ip = Arp
    data_provider = data_provider
    em = em
    mean_en = mean_en
    r = 0
    position_units = ${dom0Scale}
  [../]
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
    ip = Arp
    mean_en = mean_en
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
    ip = Arp
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
  [./Ar4s_physical_right_advection]
    type = HagelaarIonAdvectionBC
    variable = Ar4s
    boundary = 'right'
    potential = potential
    r = 0
    position_units = ${dom0Scale}
  [../]
  [./Ar4s_physical_left_advection]
    type = HagelaarIonAdvectionBC
    variable = Ar4s
    boundary = 'left'
    potential = potential
    r = 0
    position_units = ${dom0Scale}
  [../]
  [./Ar4s_physical_right_diffusion]
    type = HagelaarIonDiffusionBC
    variable = Ar4s
    boundary = 'right'
    r = 0
    position_units = ${dom0Scale}
  [../]
  [./Ar4s_physical_left_diffusion]
    type = HagelaarIonDiffusionBC
    variable = Ar4s
    boundary = 'left'
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
    value = -21
    block = 0
  [../]
  [./Arp_ic]
    type = ConstantIC
    variable = Arp
    value = -21
    block = 0
  [../]
  [./Ar4s_ic]
    type = ConstantIC
    variable = Ar4s
    value = -41
    #value = -21
    block = 0
  [../]
  [./mean_en_ic]
    type = ConstantIC
    variable = mean_en
    value = -20
    block = 0
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
    value = 1.25
  [../]
  [./potential_ic_func]
    type = ParsedFunction
    value = '-1.25 * (1.0001e-3 - x)'
  [../]
[]

[Materials]
  [./gas_block]
    type = GasBase
    interp_trans_coeffs = true
    interp_elastic_coeff = true
    ramp_trans_coeffs = false
    em = em
    potential = potential
    ip = Arp
    mean_en = mean_en
    user_se_coeff = .05
    block = 0
    property_tables_file = td_argon_mean_en.txt
 [../]
 [./gas_species_0]
   type = HeavySpeciesMaterial
   heavy_species_name = Arp
   heavy_species_mass = 6.64e-26
   heavy_species_charge = 1.0
   #property_tables_file = td_argon_mean_en.txt
   block = 0
 [../]
 [./gas_species_1]
   type = HeavySpeciesMaterial
   heavy_species_name = Ar4s
   heavy_species_mass = 6.64e-26
   heavy_species_charge = 0.0
   block = 0
 [../]



[]
