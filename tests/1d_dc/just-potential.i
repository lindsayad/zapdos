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
  kernel_coverage_check = false
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
  num_steps = 10
  petsc_options = '-snes_converged_reason -ksp_converged_reason -snes_linesearch_monitor -ksp_monitor_true_residual -ksp_monitor_singular_value'
  solve_type = PJFNK
  petsc_options_iname = '-pc_type -snes_linesearch_minlambda'
  petsc_options_value = 'ilu       1e-3'
  nl_rel_tol = 1e-4
  nl_abs_tol = 1e-9
  dtmin = 1e-3
  l_max_its = 30
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


[Kernels]
  [./potential_diffusion_dom1]
    # type = CoeffDiffusionLin
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
    value = -125
  [../]
  [./potential_dirichlet_right]
    type = DirichletBC
    variable = potential
    boundary = right
    value = 0
  [../]
[]
