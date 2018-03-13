dtu = 1e3

[Mesh]
  type = GeneratedMesh
  nx = 100
  dim = 1
[]

[Preconditioning]
  [./smp]
    type = FDP
    full = true
  [../]
[]

[Executioner]
  petsc_options = '-ksp_monitor_true_residual -snes_converged_reason -snes_linesearch_monitor -ksp_converged_reason'
  solve_type = PJFNK
  type = Transient
  num_steps = 2
  dt = ${dtu}
  dtmin = ${dtu}
  scheme = implicit-euler
[]

[Outputs]
  print_linear_residuals = false
[]

[Kernels]
  [./potential_diffusion_dom1]
    type = Diffusion
    variable = potential
  [../]
  [./potential_dummy_td]
    type = TimeDerivative
    variable = potential
  [../]
[]

[Variables]
  [./potential]
  [../]
[]

[BCs]
  [./potential_dirichlet_left]
    type = DirichletBC
    variable = potential
    boundary = left
    value = 0
  [../]
  [./potential_dirichlet_right]
    type = DirichletBC
    variable = potential
    boundary = right
    value = 1
  [../]
[]

[Postprocessors]
  [./lin]
    type = NumLinearIterations
  [../]
  [./tot_lin]
    type = CumulativeValuePostprocessor
    postprocessor = lin
  [../]
[]
