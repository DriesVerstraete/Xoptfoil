!  This file is part of XOPTFOIL.

!  XOPTFOIL is free software: you can redistribute it and/or modify
!  it under the terms of the GNU General Public License as published by
!  the Free Software Foundation, either version 3 of the License, or
!  (at your option) any later version.

!  XOPTFOIL is distributed in the hope that it will be useful,
!  but WITHOUT ANY WARRANTY; without even the implied warranty of
!  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
!  GNU General Public License for more details.

!  You should have received a copy of the GNU General Public License
!  along with XOPTFOIL.  If not, see <http://www.gnu.org/licenses/>.

!  Copyright (C) 2014 -- 2016 Daniel Prosser

program main

! Main program for airfoil optimization

  use vardef
  use input_output,        only : read_inputs, read_clo
  use optimization,        only : pso_options_type, ds_options_type
  use airfoil_operations,  only : get_seed_airfoil, get_split_points,          &
                                  split_airfoil, deallocate_airfoil
  use parameterization,    only : create_shape_functions,                      &
                                  deallocate_shape_functions
  use optimization_driver, only : optimize, write_final_design

  implicit none

  type(airfoil_type) :: buffer_foil
  character(80) :: search_type, global_search, local_search, seed_airfoil,     &
                   airfoil_file, matchfoil_file
  character(4) :: naca_digits
  character(80) :: input_file, output_prefix
  type(pso_options_type) :: pso_options
  type(ds_options_type) :: ds_options
  integer :: pointst, pointsb, steps, fevals, nshapedvtop, nshapedvbot 
  double precision, dimension(:), allocatable :: optdesign, modest, modesb
  integer, dimension(:), allocatable :: constrained_dvs
  double precision :: fmin

  write(*,*)
  write(*,*) 'This is XoptFoil: airfoil optimization with XFOIL'
  write(*,*) 'Copyright 2014 -- 2016 Daniel Prosser'

! Read command line arguments

  call read_clo(input_file, output_prefix)

! Read inputs from namelist file

  call read_inputs(input_file, search_type, global_search, local_search,       &
                   seed_airfoil, airfoil_file, naca_digits, nparams_top,       &
                   nparams_bot, constrained_dvs, pso_options, ds_options,      &
                   matchfoil_file)

! Load seed airfoil into memory, including transformations and smoothing

  call get_seed_airfoil(seed_airfoil, airfoil_file, naca_digits, buffer_foil)

! Split up seed airfoil into upper and lower surfaces

  call get_split_points(buffer_foil, pointst, pointsb, symmetrical)
  allocate(xseedt(pointst))
  allocate(zseedt(pointst))
  allocate(xseedb(pointsb))
  allocate(zseedb(pointsb))
  call split_airfoil(buffer_foil, xseedt, xseedb, zseedt, zseedb, symmetrical)

! Deallocate the buffer airfoil (no longer needed)

  call deallocate_airfoil(buffer_foil)

! Allocate optimal solution

  if (trim(shape_functions) == 'naca') then
    nshapedvtop = nparams_top
    nshapedvbot = nparams_bot
  else
    nshapedvtop = nparams_top*3
    nshapedvbot = nparams_bot*3
  end if
  if (.not. symmetrical) then
    allocate(optdesign(nshapedvtop+nshapedvbot+nflap_optimize))
  else
    allocate(optdesign(nshapedvtop+nflap_optimize))
  end if

! Optimize
  
  call optimize(search_type, global_search, local_search, matchfoil_file,      &
                constrained_dvs, pso_options, ds_options, optdesign, fmin,     &
                steps, fevals)

! Notify of total number of steps and function evals

  write(*,*)
  write(*,*) 'Optimization complete. Totals: '
  write(*,*) '  Steps: ', steps, ' Objective function evaluations: ', fevals

! Write final design and summary

  allocate(modest(nshapedvtop))
  allocate(modesb(nshapedvbot))
  modest(:) = 0.d0
  modesb(:) = 0.d0
  call create_shape_functions(xseedt, xseedb, modest, modesb, shape_functions, &
                              first_time = .true.) ! Needed because parallel
                                        ! optimization allocates shape functions 
                                        ! on each thread and then deallocates
  call write_final_design(optdesign, shape_functions, output_prefix)

! Deallocate other memory

  deallocate(xseedt)
  deallocate(xseedb)
  deallocate(zseedt)
  deallocate(zseedb)
  deallocate(modest)
  deallocate(modesb)
  deallocate(optdesign)
  deallocate(constrained_dvs)
  call deallocate_shape_functions()

end program main
