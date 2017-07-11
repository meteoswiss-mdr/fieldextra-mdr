#!/bin/tcsh 

unlimit stacksize

#NEW TEST 8/7/2014
# to be modified in order to select the wanted day 
set dds =   (  21)
set mms =   (  06)
set yyyys = (2012)
set yys =   (  12) 
set hh =    (  00)
set levellist = "levmin=1,levmax=61"
set levellist1 = "levmin=1,levmax=60"
set levellist2 = "levmin=50,levmax=60"
set levellist3 = "levmin=58,levmax=60"
set tstops = ( 23 )
set tstarts = ( 0 )
@ ndays = 1

########################################
set fieldextra = /users/osm/opr/abs/
#get cosmo analysis data
set archivedirs = (/store/s83/osm/LA)
set files = (lfff00000000 lfff00010000 lfff00020000 lfff00030000 lfff00040000 lfff00050000 lfff00060000 lfff00070000 lfff00080000 lfff00090000 lfff00100000 lfff00110000 lfff00120000 lfff00130000 lfff00140000 lfff00150000 lfff00160000 lfff00170000 lfff00180000 lfff00190000 lfff00200000 lfff00210000 lfff00220000 lfff00230000)

set wdir = /store/s83/strefalt/phd_wind_hail/data/model/cosmo-2/LA
set LM_LDIR = /users/osm/opr/lib/
set absfieldextra = /oprusers/osm/opr/abs/fieldextra_11.3.0_gnu4.5.3_opt_omp
set fieldextra = 1
set extraction = 1
########################################

@ n = 0
while ($n < $ndays)

@ m = 1
foreach model ($archivedirs)

    @ d = 1
    foreach day ($dds)
    
    #get cosmo analysis data on fine grid 
    set yyyy=$yyyys[$d]
    set yy=$yys[$d]
    set mm=$mms[$d]
    set dd=$dds[$d]
    set adir=$archivedirs$yy/$yyyy$mm$dd/fine
    echo "-----------------------------------------------------------------------------"
    echo "archive directory of cosmo analysis (fine): $adir"
     
    #working directory for analysis data
    #create if it doesnt exist yet
    set destination = $wdir/${yyyy}${mm}${dd}_ana
    if (! -d $destination) then
          mkdir $destination
        endif
    echo "working directory of cosmo analysis (fine): $destination"

    #stage whole day and transfer it
    if ($extraction == 1 ) then
      echo "start staging"
      date
      #stage -w -r $adir
      cp ${adir}/laf* $destination/
      echo "files staged and copied"
      date

    #rename files
    @ nh = 0
    while ($nh < 24)
       @ nnh = $nh + 1 
       set tmp3 = `/oprusers/osm/bin/addtime -Y $yyyy -M $mm -D $dd -H $hh -T $nh`
       mv ${destination}/laf$tmp3[1]$tmp3[2]$tmp3[3]$tmp3[4] ${destination}/$files[$nnh]
    @ nh = $nh + 1
    end
    echo "files renamed"
 
    #copy constant file
    #cp $wdir/lfff00000000c_fine ${destination}/lfff00000000c
    endif

    #fieldextra job	
    if ($fieldextra == 1 ) then
       echo "start fieldextra"
       date 
       rm -f $wdir/nl1.NTC
       rm -f $wdir/nl2.NTC

@ t = 1
foreach tstart ($tstarts)
set tstop = $tstops[$t]

echo "START-STOP: $tstart $tstop"

cat << EOFNTC >! $destination/n2.NTC  


!---------------------------------------------------------------------------------------
! Global specifications (compulsive):
!---------------------------------------------------------------------------------------
&RunSpecification
 strict_nl_parsing     = .true.
 verbosity             = "high"
 diagnostic_length     = 110
 soft_memory_limit     = 13
/

&GlobalResource
 dictionary            = "/oprusers/osm/opr/lib/dictionary_cosmo.txt"
 grib_definition_path  = "/oprusers/osm/opr/lib/fieldextra_grib_api_definitions"
/

&GlobalSettings
 default_dictionary    = "cosmo"
 default_model_name    = "cosmo-2"
/ 

&ModelSpecification
 model_name            = "cosmo-2"
 earth_axis_large      = 6371229.
 earth_axis_small      = 6371229.
/

!---------------------------------------------------------------------------------------
! Define input and output characteristics, define domain subset:
!---------------------------------------------------------------------------------------

&Process
  in_file  = "$destination/lfff00000000"
  out_type = "INCORE" /
&Process in_field = "HSURF",tag="HSURF"/
&Process in_field = "FR_LAND"/





!---------------------------------------------
! Fields 1------------------------------------
!---------------------------------------------
&Process
  in_type = "INCORE"
  tstart=$tstart, tstop=$tstop, tincr=1 
  out_file="$destination/$yyyy$mm$dd${hh}_<HH>_cosmo2_CAPE"
  out_type="GRIB1"
  imin=180, jmin=70, imax=300, jmax=200 
/
&Process in_field = "HHL", levmin=1, levmax=61 /
&Process in_field = "HSURF" /

&Process
  in_file="$destination/lfff<DDHH>0000"
  tstart=$tstart, tstop=$tstop, tincr=1 
  out_file="$destination/$yyyy$mm$dd${hh}_<HH>_cosmo2_CAPE"
  imin=180, jmin=70, imax=300, jmax=200
  out_type="GRIB1"
/
!---------------------------------------------------------------------------------------
! Define fields to extract:
!---------------------------------------------------------------------------------------
&Process in_field = "P",$levellist1/
&Process in_field = "QV",$levellist1/
&Process in_field = "T",$levellist1/

&Process out_field = "CIN_MU" /
&Process out_field = "CAPE_MU" /
&Process out_field = "LFC_ML" /
&Process out_field = "SLI" /





!---------------------------------------------
! Fields 2------------------------------------
!---------------------------------------------
&Process
  in_type = "INCORE"
  out_file="$destination/$yyyy$mm$dd${hh}_<HH>_cosmo2_FFDD" 
  tstart=$tstart, tstop=$tstop, tincr=1 
  out_type="GRIB1"
  imin=180, jmin=70, imax=300, jmax=200
  in_grid="HSURF", in_grid_intpl="average,square,0.9"
/
&Process in_field = "HHL", levmin=1, levmax=61 /
&Process in_field = "HSURF"/

&Process
  in_file="$destination/lfff<DDHH>0000"
  tstart=$tstart, tstop=$tstop, tincr=1 
  out_file="$destination/$yyyy$mm$dd${hh}_<HH>_cosmo2_FFDD"
  out_type="GRIB1"
  imin=180, jmin=70, imax=300, jmax=200
  in_grid="HSURF", in_grid_intpl="average,square,0.9"
/
!---------------------------------------------------------------------------------------
! Define fields to extract:
!---------------------------------------------------------------------------------------
&Process in_field = "U",$levellist1,regrid=.t./
&Process in_field = "V",$levellist1,regrid=.t./
&Process in_field = "P",$levellist1/
&Process in_field = "PMSL"/

&Process tmp1_field = "HFL" /
&Process tmp1_field = "P" /
&Process tmp1_field = "U",voper="intpl_k2z,lnp",voper_lev=1500,3000,4000/
&Process tmp1_field = "V",voper="intpl_k2z,lnp",voper_lev=1500,3000,4000/
!---------------------------------------------------------------------------------------
! Define output fields:
!---------------------------------------------------------------------------------------
&Process out_field = "FF" /
&Process out_field = "DD" /





!---------------------------------------------
! Fields 3------------------------------------
!---------------------------------------------
&Process
  in_type = "INCORE"
  out_file="$destination/$yyyy$mm$dd${hh}_<HH>_cosmo2_HUM" 
  tstart=$tstart, tstop=$tstop, tincr=1 
  out_type="GRIB1"
  imin=180, jmin=70, imax=300, jmax=200
/
&Process in_field = "HHL", levmin=1, levmax=61 /
&Process in_field = "HSURF"/

&Process
  in_file="$destination/lfff<DDHH>0000"
  tstart=$tstart, tstop=$tstop, tincr=1 
  out_file="$destination/$yyyy$mm$dd${hh}_<HH>_cosmo2_HUM"
  out_type="GRIB1"
  imin=180, jmin=70, imax=300, jmax=200
/
!---------------------------------------------------------------------------------------
! Define fields to extract:
!---------------------------------------------------------------------------------------
&Process in_field = "QV",$levellist1/
&Process in_field = "T",$levellist1/
&Process in_field = "P",$levellist1/
&Process in_field = "PS"/
&Process in_field = "T_2M"/
&Process in_field = "TD_2M"/

&Process tmp1_field = "PS"/
&Process tmp1_field = "P",$levellist1/
&Process tmp1_field = "T_2M"/
&Process tmp1_field = "TD_2M"/
&Process tmp1_field = "T",$levellist3/
&Process tmp1_field = "QV",$levellist3/


!---------------------------------------------------------------------------------------
! Define output fields:
!---------------------------------------------------------------------------------------
&Process out_field = "TD_2M"/
&Process out_field = "QV_2M"/
&Process out_field = "THETAE_2M"/
&Process out_field = "TD"/





!---------------------------------------------
! Fields 5------------------------------------
!---------------------------------------------
&Process
  in_type = "INCORE"
  out_file="$destination/$yyyy$mm$dd${hh}_<HH>_cosmo2_SHEAR" 
  tstart=$tstart, tstop=$tstop, tincr=1 
  out_type="GRIB1"
  imin=180, jmin=70, imax=300, jmax=200
  in_grid="HSURF", in_grid_intpl="average,square,0.9"
/
&Process in_field = "HHL", levmin=1, levmax=61 /
&Process in_field = "HSURF"/

&Process
  in_file="$destination/lfff<DDHH>0000"
  tstart=$tstart, tstop=$tstop, tincr=1 
  out_file="$destination/$yyyy$mm$dd${hh}_<HH>_cosmo2_SHEAR"
  out_type="GRIB1"
  imin=180, jmin=70, imax=300, jmax=200
  in_grid="HSURF", in_grid_intpl="average,square,0.9"
/
!---------------------------------------------------------------------------------------
! Define fields to extract:
!---------------------------------------------------------------------------------------
&Process in_field = "U", $levellist1, regrid=.t./
&Process in_field = "V", $levellist1, regrid=.t./
&Process in_field = "P", $levellist1 /
&Process in_field = "PMSL"/
&Process tmp1_field = "P", /
&Process tmp1_field = "HFL", /
&Process tmp1_field = "U", voper="intpl_k2z,lnp", voper_lev=3000,6000, hoper='diskavg,3', tag="smooth_u_on_z" /
&Process tmp1_field = "V", voper="intpl_k2z,lnp", voper_lev=3000,6000, hoper='diskavg,3', tag="smooth_v_on_z" /
&Process tmp1_field = "U", $levellist1, tag="smooth_u_on_k", hoper='diskavg,3' /
&Process tmp1_field = "V", $levellist1, tag="smooth_v_on_k", hoper='diskavg,3'/
&Process tmp1_field = "U", voper="intpl_k2z,lnp", voper_lev=3000,6000, tag="u_on_z" /
&Process tmp1_field = "V", voper="intpl_k2z,lnp", voper_lev=3000,6000, tag="v_on_z" /
&Process tmp1_field = "U", $levellist1, tag="u_on_k" /
&Process tmp1_field = "V", $levellist1, tag="v_on_k"/

&Process tmp2_field = "smooth_u_on_z", tag="smooth_u_for_wshear" /
&Process tmp2_field = "smooth_v_on_z", tag="smooth_v_for_wshear" /
&Process tmp2_field = "smooth_u_on_k", tag="smooth_u_for_wshear" /
&Process tmp2_field = "smooth_v_on_k", tag="smooth_v_for_wshear" /
&Process tmp2_field = "u_on_z", tag="u_for_wshear" /
&Process tmp2_field = "v_on_z", tag="v_for_wshear" /
&Process tmp2_field = "u_on_k", tag="u_for_wshear" /
&Process tmp2_field = "v_on_k", tag="v_for_wshear" /

!---------------------------------------------------------------------------------------
! Define output fields:
!---------------------------------------------------------------------------------------
&Process out_field = "WSHEAR_0-3km", use_tag="u_for_wshear,v_for_wshear", tag="WSHEAR_0-3km" /
&Process out_field = "WSHEAR_0-6km", use_tag="u_for_wshear,v_for_wshear", tag="WSHEAR_0-6km" /





!---------------------------------------------
! Fields 6 -----------------------------------
!---------------------------------------------

&Process
  in_type = "INCORE"
  tstart=$tstart, tstop=$tstop, tincr=1, 
  out_file="$destination/$yyyy$mm$dd${hh}_<HH>_cosmo2_MCONV"
  out_type="GRIB1"
  in_grid="HSURF"/
  
&Process in_field = "HHL", $levellist /
&Process in_field = "HFL", $levellist1 /
&Process in_field = "HSURF" /

&Process 
  in_file="$destination/lfff<DDHH>0000"
  tstart=$tstart, tstop=$tstop, tincr=1,
  out_file="$destination/$yyyy$mm$dd${hh}_<HH>_cosmo2_MCONV"
  out_type="GRIB1"
  in_grid="HSURF"/

!---------------------------------------------------------------------------------------
! Define fields to extract:
!---------------------------------------------------------------------------------------
&Process in_field = "P",$levellist1/
&Process in_field = "QV",$levellist1/
&Process in_field = "U",$levellist1/
&Process in_field = "V",$levellist1/

&Process tmp1_field = "HSURF" /
&Process tmp1_field = "HHL" /
&Process tmp1_field = "HFL" /
&Process tmp1_field = "P" /
&Process tmp1_field = "MCONV", voper = "integ_sfc2h", voper_lev = 200/
&Process tmp1_field = "U", hoper="destagger", voper="intpl_k2h,lnp", voper_lev = 200 /
&Process tmp1_field = "V", hoper="destagger", voper="intpl_k2h,lnp", voper_lev = 200 /

&Process out_field = "MCONV",tag='MCONV' /





!---------------------------------------------
! Fields 7------------------------------------
!---------------------------------------------
&Process
  in_type = "INCORE"
  tstart=$tstart, tstop=$tstop, tincr=1 
  out_file="$destination/$yyyy$mm$dd${hh}_<HH>_cosmo2_SWEAT"
  out_type="GRIB1"
  imin=180, jmin=70, imax=300, jmax=200 
/
&Process in_field = "HHL", levmin=1, levmax=61 /
&Process in_field = "HSURF" /

&Process
  in_file="$destination/lfff<DDHH>0000"
  tstart=$tstart, tstop=$tstop, tincr=1 
  out_file="$destination/$yyyy$mm$dd${hh}_<HH>_cosmo2_SWEAT"
  imin=180, jmin=70, imax=300, jmax=200
  out_type="GRIB1"
/
!---------------------------------------------------------------------------------------
! Define fields to extract:
!---------------------------------------------------------------------------------------
&Process in_field = "P",$levellist1/
&Process in_field = "QV",$levellist1/
&Process in_field = "T",$levellist1/
&Process in_field = "U",$levellist1/
&Process in_field = "V",$levellist1/

&Process tmp1_field = "HSURF" /
&Process tmp1_field = "HHL" /

&Process out_field = "SWEAT" /
&Process out_field = "DCI" /








EOFNTC

    $absfieldextra $destination/n2.NTC # $destination/logfieldextra1
@ t = $t + 1 
end
        set ore = ( 00 01 02 03 04 05 06 07 08 09 10 11 12 13 14 15 16 17 18 19 20 21 22 23)
        #foreach ora ($ore) 
          #rm -f $destination/$yyyy$mm$dd${hh}_${ora}_cosmo2
          #cat $destination/$yyyy$mm$dd${hh}_${ora}_cosmo2_* > $destination/$yyyy$mm$dd${hh}_${ora}_cosmo2
          #rm -f $destination/$yyyy$mm$dd${hh}_${ora}_cosmo2_*
        #end
	#rm -f $destination/tmp/*.tmp
        rm -f $destination/lfff*
        #mv $destination/tmp/NWP* $wdir
        
       endif

    @ d = $d + 1
    end
    
    @ m = $m + 1 
end

@ n = $n + 1
end
