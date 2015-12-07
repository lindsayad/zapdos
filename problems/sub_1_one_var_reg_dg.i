[Mesh]
  type = GeneratedMesh
  dim = 1
  nx = 2
  xmax = 1
[]


[Variables]
  [./u]
    order = FIRST
    family = MONOMIAL
  [../]
[]

[Kernels]
  [./test_u]
    type = Diffusion
    variable = u
  [../]
[]

[DGKernels]
  [./dg_advection]
    type = DGAdvection
    variable = u
    vx = 1
    vy = 0
    vz = 0
  [../]
[]

# [BCs]
#   [./left]
#     type = DirichletBC
#     variable = u
#     boundary = 'left'
#     value = 1
#   [../]
#   [./right]
#     type = DirichletBC
#     variable = u
#     boundary = 'right'
#     value = 0
#   [../]
# []

[ICs]
  [./u_ic]
    type = RandomIC
    variable = u
  [../]
[]

[Materials]
  [./jac]
    block = '0'
    type = JacMat
  [../]
[]

[Preconditioning]
  [./fdp]
    type = SMP
    full = true
  [../]
[]

[Executioner]
  # type = Transient
  # dt = 0.1
  # end_time = 1
  type = Steady
  solve_type = NEWTON
  petsc_options = '-snes_converged_reason  -pc_svd_monitor -snes_linesearch_monitor -options_left -snes_test_display'
  petsc_options_iname = '-snes_type'
  petsc_options_value = 'test'
[]

[Outputs]
  exodus = true
  print_linear_residuals = false
[]

[Debug]
  show_var_residual_norms = true
[]