module writers_m
    ! Module for writing the data to output files.
    ! Contains subroutines to write the system data and positions.

    use, intrinsic :: iso_fortran_env, only: dp => real64, i64 => int64, error_unit
    implicit none

    contains

    subroutine writeSystem(unit,lj_epsilon,lj_sigma,mass, time,E,Epot,Ekin,T,press,MSD,momentum)
        ! Writes system data to the main output file.Changes reduced units 
        ! used in simulation to real units.
        ! unit : file unit to write on.
        ! lj_epsilon : Lennard Jones epsilon parameter for the gas (in kJ/mol)
        ! lj_sigma : Lennard Jones sigma parameter for the gas (in Ang)
        ! mass : Molar Mass of the gas (g/mol)
        
        integer(kind=i64), intent(in) :: unit
        double precision, intent(in) :: lj_epsilon,lj_sigma,mass
        double precision, intent(in) :: time,E,Epot,Ekin,T,press,MSD,momentum
        double precision :: time_out,E_out,Epot_out,Ekin_out,T_out,press_out,MSD_out,momentum_out
        double precision :: ru_time,ru_dens,ru_dist,ru_temp,ru_E,ru_press,ru_vel,ru_mom
        double precision, parameter :: Na = 6.0221408d23
        double precision, parameter :: kb = 1.380649d-23

        ! Conversion factors between reduced and real units
        ru_time = sqrt(mass*(lj_sigma*1d-10)**2_i64 / (lj_epsilon*1d6))     ! t in seconds
        ru_dist = lj_sigma                                                  ! distance in Ang
        ru_dens = 1d24 * mass / (Na*lj_sigma**3_i64)                        ! density in g/mL
        ru_E = lj_epsilon                                                   ! energy in kJ/mol
        ru_press = 1d3*lj_epsilon/((lj_sigma*1d-10)**3_i64 * Na)            ! pressure in Pa
        ru_temp = 1d3*lj_epsilon/(kb*Na)                                    ! temperature in K
        ru_vel = ru_dist/ru_time *1d-10                                     ! velocity in Ang/s
        ru_mom = 1d-3*(mass/Na)*ru_vel*1d-10                                ! linear momentum in kg*m/s

        ! Multiplying the reduced value with its correspondent conversion factor
        time_out = time * ru_time
        E_out = E * ru_E
        Epot_out = Epot * ru_E
        Ekin_out = Ekin * ru_E
        T_out = T * ru_temp
        press_out = press * ru_press
        MSD_out = MSD * ru_dist**2_i64
        momentum_out = momentum * ru_mom

        ! Writes to output file (coumun style)
        write(unit,*) time_out,E_out,Epot_out,Ekin_out,T_out,press_out,MSD_out,momentum_out

    end subroutine writeSystem


    subroutine writePositions(r,unit)
        ! Writes current position in the specified file (XYZ format).
        ! In a loop, writes trajectory.
        ! r : 3xN Positions matrix. 
        ! unit : file unit to write on.
        implicit none
        double precision, intent(in),dimension(:,:) :: r
        integer(kind=i64), intent(in) :: unit
        integer(kind=i64) :: i, N

        N = size(r, dim=2,kind=i64)

        write(unit,*) N
        write(unit,*)
        do i= 1,N
            write(unit,*) "Ar", r(:,i)
        end do

    end subroutine writePositions


end module writers_m