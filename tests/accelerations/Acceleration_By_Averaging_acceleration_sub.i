dom0Scale = 25.4e-3

[GlobalParams]
  potential_units = kV
  use_moles = true
[]

[Mesh]
  type = FileMesh
  file = 'Lymberopoulos_paper.msh'
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

[Variables]
  [./em]
  [../]

  [./Ar+]
  [../]

  [./Ar*]
  [../]

  [./mean_en]
  [../]

  [./potential]
  [../]
[]

[Kernels]
#Electron Equations
#Time Derivative term of electron
  [./em_time_deriv]
    type = ElectronTimeDerivative
    variable = em
  [../]
#Advection term of electron
  [./em_advection]
    type = EFieldAdvectionElectrons
    variable = em
    potential = potential
    mean_en = mean_en
    position_units = ${dom0Scale}
  [../]
#Diffusion term of electrons
  [./em_diffusion]
    type = CoeffDiffusionElectrons
    variable = em
    mean_en = mean_en
    position_units = ${dom0Scale}
  [../]
#Net electron production from ionization
  [./em_ionization]
    type = EEDFReactionLog
    variable = em
    electrons = em
    mean_energy = mean_en
    target = Ar
    reaction = 'em + Ar -> em + em + Ar+'
    coefficient = 1
  [../]
#Net electron production from step - wise ionization
  [./em_stepwise_ionization]
    type = EEDFReactionLog
    variable = em
    electrons = em
    mean_energy = mean_en
    target = Ar*
    reaction = 'em + Ar* -> em + em + Ar+'
    coefficient = 1
  [../]
#Net electron production from metastable pooling
  [./em_pooling]
    type = ReactionSecondOrderLog
    variable = em
    v = Ar*
    w = Ar*
    reaction = 'Ar* + Ar* -> Ar+ + Ar + em'
    coefficient = 1
  [../]

#Argon Ion Equations
#Time Derivative term of the ions
  [./Ar+_time_deriv]
    type = ElectronTimeDerivative
    variable = Ar+
  [../]
#Advection term of ions
  [./Ar+_advection]
    type = EFieldAdvection
    variable = Ar+
    potential = potential
    position_units = ${dom0Scale}
  [../]
  [./Ar+_diffusion]
    type = CoeffDiffusion
    variable = Ar+
    position_units = ${dom0Scale}
  [../]
#Net ion production from ionization
  [./Ar+_ionization]
    type = EEDFReactionLog
    variable = Ar+
    electrons = em
    mean_energy = mean_en
    target = Ar
    reaction = 'em + Ar -> em + em + Ar+'
    coefficient = 1
  [../]
#Net ion production from step - wise ionization
  [./Ar+_stepwise_ionization]
    type = EEDFReactionLog
    variable = Ar+
    electrons = em
    mean_energy = mean_en
    target = Ar*
    reaction = 'em + Ar* -> em + em + Ar+'
    coefficient = 1
  [../]
#Net ion production from metastable pooling
  [./Ar+_pooling]
    type = ReactionSecondOrderLog
    variable = Ar+
    v = Ar*
    w = Ar*
    reaction = 'Ar* + Ar* -> Ar+ + Ar + em'
    coefficient = 1
  [../]

#Argon Excited Equations
#Time Derivative term of excited Argon
  [./Ar*_time_deriv]
    type = ElectronTimeDerivative
    variable = Ar*
  [../]
#Diffusion term of excited Argon
  [./Ar*_diffusion]
    type = CoeffDiffusion
    variable = Ar*
    position_units = ${dom0Scale}
  [../]
#Net excited Argon production from excitation
  [./Ar*_excitation]
    type = EEDFReactionLog
    variable = Ar*
    electrons = em
    target = Ar
    mean_energy = mean_en
    reaction = 'em + Ar -> em + Ar*'
    coefficient = 1
  [../]
#Net excited Argon loss from step - wise ionization
  [./Ar*_stepwise_ionization]
    type = EEDFReactionLog
    variable = Ar*
    electrons = em
    target = Ar*
    mean_energy = mean_en
    reaction = 'em + Ar* -> em + em + Ar+'
    coefficient = -1
  [../]
#Net excited Argon loss from superelastic collisions
  [./Ar*_collisions]
    type = EEDFReactionLog
    variable = Ar*
    electrons = em
    target = Ar*
    mean_energy = mean_en
    reaction = 'em + Ar* -> em + Ar'
    coefficient = -1
  [../]
#Net excited Argon loss from quenching to resonant
  [./Ar*_quenching]
    type = EEDFReactionLog
    variable = Ar*
    electrons = em
    target = Ar*
    mean_energy = mean_en
    reaction = 'em + Ar* -> em + Ar_r'
    coefficient = -1
  [../]
#Net excited Argon loss from metastable pooling
  [./Ar*_pooling]
    type = ReactionSecondOrderLog
    variable = Ar*
    v = Ar*
    w = Ar*
    reaction = 'Ar* + Ar* -> Ar+ + Ar + em'
    coefficient = -2
    _v_eq_u = true
    _w_eq_u = true
  [../]
#Net excited Argon loss from two - body quenching
  [./Ar*_2B_quenching]
    type = ReactionSecondOrderLog
    variable = Ar*
    v = Ar*
    w = Ar
    reaction = 'Ar* + Ar -> Ar + Ar'
    coefficient = -1
    _v_eq_u = true
  [../]
#Net excited Argon loss from three - body quenching
  [./Ar*_3B_quenching]
    type = ReactionThirdOrderLog
    variable = Ar*
    v = Ar*
    w = Ar
    x = Ar
    reaction = 'Ar* + Ar + Ar -> Ar_2 + Ar'
    coefficient = -1
    _v_eq_u = true
  [../]
#Voltage Equations
#Voltage term in Poissons Eqaution
  [./potential_diffusion_dom0]
    type = CoeffDiffusionLin
    variable = potential
    position_units = ${dom0Scale}
  [../]
#Ion term in Poissons Equation
  [./Ar+_charge_source]
    type = ChargeSourceMoles_KV
    variable = potential
    charged = Ar+
  [../]
#Electron term in Poissons Equation
  [./em_charge_source]
    type = ChargeSourceMoles_KV
    variable = potential
    charged = em
  [../]

#Electron Energy Equations
#Time Derivative term of electron energy
  [./mean_en_time_deriv]
    type = ElectronTimeDerivative
    variable = mean_en
  [../]
#Advection term of electron energy
  [./mean_en_advection]
    type = EFieldAdvectionEnergy
    variable = mean_en
    potential = potential
    em = em
    position_units = ${dom0Scale}
  [../]
#Diffusion term of electrons energy
  [./mean_en_diffusion]
    type = CoeffDiffusionEnergy
    variable = mean_en
    em = em
    position_units = ${dom0Scale}
  [../]
#Joule Heating term
  [./mean_en_joule_heating]
    type = JouleHeating
    variable = mean_en
    potential = potential
    em = em
    position_units = ${dom0Scale}
  [../]
#Energy loss from ionization
  [./Ionization_Loss]
    type = EEDFEnergyLog
    variable = mean_en
    electrons = em
    target = Ar
    reaction = 'em + Ar -> em + em + Ar+'
    threshold_energy = -15.7
  [../]
#Energy loss from excitation
  [./Excitation_Loss]
    type = EEDFEnergyLog
    variable = mean_en
    electrons = em
    target = Ar
    reaction = 'em + Ar -> em + Ar*'
    threshold_energy = -11.56
  [../]
#Energy loss from step - wise ionization
  [./Stepwise_Ionization_Loss]
    type = EEDFEnergyLog
    variable = mean_en
    electrons = em
    target = Ar*
    reaction = 'em + Ar* -> em + em + Ar+'
    threshold_energy = -4.14
  [../]
#Energy gain from superelastic collisions
  [./Collisions_Loss]
    type = EEDFEnergyLog
    variable = mean_en
    electrons = em
    target = Ar*
    reaction = 'em + Ar* -> em + Ar'
    threshold_energy = 11.56
  [../]
[]

[AuxVariables]
  [./Ar]
  [../]
[]

[AuxKernels]
  [./Ar_val]
    type = ConstantAux
    variable = Ar
    #value = 3.22e22
    value = -2.928623
    execute_on = INITIAL
  [../]
[]

[BCs]
#Voltage Boundary Condition
  [./potential_left]
    type = FunctionDirichletBC
    variable = potential
    boundary = 'left'
    function = potential_bc_func
  [../]
  [./potential_dirichlet_right]
    type = DirichletBC
    variable = potential
    boundary = 'right'
    value = 0
  [../]

#Boundary conditions for electons
  [./em_physical_right]
    type = LymberopoulosElectronBC
    variable = em
    boundary = 'right'
    gamma = 0.01
    #gamma = 1
    ks = 1.19e5
    #ks = 0.0
    ion = Ar+
    potential = potential
    position_units = ${dom0Scale}
  [../]
  [./em_physical_left]
    type = LymberopoulosElectronBC
    variable = em
    boundary = 'left'
    gamma = 0.01
    #gamma = 1
    ks = 1.19e5
    #ks = 0.0
    ion = Ar+
    potential = potential
    position_units = ${dom0Scale}
  [../]

#Boundary conditions for ions
  [./Ar+_physical_right_advection]
    type = LymberopoulosIonBC
    variable = Ar+
    potential = potential
    boundary = 'right'
    position_units = ${dom0Scale}
  [../]
  [./Ar+_physical_left_advection]
    type = LymberopoulosIonBC
    variable = Ar+
    potential = potential
    boundary = 'left'
    position_units = ${dom0Scale}
  [../]

#Boundary conditions for ions Metastable
  [./Ar*_physical_right_diffusion]
    type = LogDensityDirichletBC
    variable = Ar*
    boundary = 'right'
    value = 1e-5
  [../]
  [./Ar*_physical_left_diffusion]
    type = LogDensityDirichletBC
    variable = Ar*
    boundary = 'left'
    value = 1e-5
  [../]

#Boundary conditions for electron mean energy
  [./mean_en_physical_right]
    type = ElectronTemperatureDirichletBC
    variable = mean_en
    em = em
    value = 0.5
    boundary = 'right'
  [../]
  [./mean_en_physical_left]
    type = ElectronTemperatureDirichletBC
    variable = mean_en
    em = em
    value = 0.5
    boundary = 'left'
  [../]
[]

[Functions]
  [./potential_bc_func]
    type = ParsedFunction
    value = '0.100*sin(2*pi*13.56e6*t)'
  [../]
[]

[Materials]
  [./GasBasics]
    type = GasElectronMoments
    interp_trans_coeffs = false
    interp_elastic_coeff = false
    ramp_trans_coeffs = false
    user_p_gas = 133.322
    em = em
    potential = potential
    mean_en = mean_en
    user_electron_mobility = 30.0
    user_electron_diffusion_coeff = 119.8757763975
    property_tables_file = Argon_reactions_paper_RateCoefficients/electron_moments.txt
    position_units = ${dom0Scale}
  [../]
  [./gas_species_0]
    type = HeavySpeciesMaterial
    heavy_species_name = Ar+
    heavy_species_mass = 6.64e-26
    heavy_species_charge = 1.0
    mobility = 0.144409938
    diffusivity = 6.428571e-3
  [../]
  [./gas_species_1]
    type = HeavySpeciesMaterial
    heavy_species_name = Ar*
    heavy_species_mass = 6.64e-26
    heavy_species_charge = 0.0
    diffusivity = 7.515528e-3
  [../]
  [./gas_species_2]
    type = HeavySpeciesMaterial
    heavy_species_name = Ar
    heavy_species_mass = 6.64e-26
    heavy_species_charge = 0.0
  [../]
  [./reaction_0]
    type = ZapdosEEDFRateConstant
    mean_energy = mean_en
    property_file = 'Argon_reactions_paper_RateCoefficients/reaction_em + Ar -> em + Ar*.txt'
    reaction = 'em + Ar -> em + Ar*'
    position_units = ${dom0Scale}
    file_location = ''
    electrons = em
  [../]
  [./reaction_1]
    type = ZapdosEEDFRateConstant
    mean_energy = mean_en
    property_file = 'Argon_reactions_paper_RateCoefficients/reaction_em + Ar -> em + em + Ar+.txt'
    reaction = 'em + Ar -> em + em + Ar+'
    position_units = ${dom0Scale}
    file_location = ''
    electrons = em
  [../]
  [./reaction_2]
    type = ZapdosEEDFRateConstant
    mean_energy = mean_en
    property_file = 'Argon_reactions_paper_RateCoefficients/reaction_em + Ar* -> em + Ar.txt'
    reaction = 'em + Ar* -> em + Ar'
    position_units = ${dom0Scale}
    file_location = ''
    electrons = em
  [../]
  [./reaction_3]
    type = ZapdosEEDFRateConstant
    mean_energy = mean_en
    property_file = 'Argon_reactions_paper_RateCoefficients/reaction_em + Ar* -> em + em + Ar+.txt'
    reaction = 'em + Ar* -> em + em + Ar+'
    position_units = ${dom0Scale}
    file_location = ''
    electrons = em
  [../]
  [./reaction_4]
    type = GenericRateConstant
    reaction = 'em + Ar* -> em + Ar_r'
    #reaction_rate_value = 2e-13
    reaction_rate_value = 1.2044e11
  [../]
  [./reaction_5]
    type = GenericRateConstant
    reaction = 'Ar* + Ar* -> Ar+ + Ar + em'
    #reaction_rate_value = 6.2e-16
    reaction_rate_value = 373364000
  [../]
  [./reaction_6]
    type = GenericRateConstant
    reaction = 'Ar* + Ar -> Ar + Ar'
    #reaction_rate_value = 3e-21
    reaction_rate_value = 1806.6
  [../]
  [./reaction_7]
    type = GenericRateConstant
    reaction = 'Ar* + Ar + Ar -> Ar_2 + Ar'
    #reaction_rate_value = 1.1e-43
    reaction_rate_value = 39890.9324
  [../]
[]

#New postprocessor that calculates the inverse of the plasma frequency
[Postprocessors]
  [./InversePlasmaFreq]
    type = PlasmaFrequencyInverse
    variable = em
    use_moles = true
    execute_on = 'INITIAL TIMESTEP_BEGIN'
  [../]
[]

[Preconditioning]
  active = 'smp'
  [./smp]
    type = SMP
    full = true
  [../]

  [./fdp]
    type = FDP
    full = true
  [../]
[]

[Executioner]
  type = Transient
  end_time = 73.74631268e-9
  petsc_options = '-snes_converged_reason -snes_linesearch_monitor'
  solve_type = NEWTON
  petsc_options_iname = '-pc_type -pc_factor_shift_type -pc_factor_shift_amount -ksp_type -snes_linesearch_minlambda'
  petsc_options_value = 'lu NONZERO 1.e-10 fgmres 1e-3'
  dtmin = 1e-14
  l_max_its = 20
  scheme = bdf2
  dt = 1e-9
[]

[Outputs]
  perf_graph = true
  [./out]
    type = Exodus
  [../]
[]
