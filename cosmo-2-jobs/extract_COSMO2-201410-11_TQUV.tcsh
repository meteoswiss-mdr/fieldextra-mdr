#!/bin/tcsh 

unlimit stacksize

#-----------------------------------------------
# SCRIPT TO EXTRACT COSMO-2 DATA
# HOURLY
# U,V,T,Q
# CAPE_MU, CAPE_ML, CIN_MU, CIN_ML, TQV


# to be modified in order to select the wanted day 
set dds =   (  01 02 03 04 05 06 07 08 09 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31 01 02 03 04 05 06 07 08 09 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30)
set mms =   (  10 10 10 10 10 10 10 10 10 10 10 10 10 10 10 10 10 10 10 10 10 10 10 10 10 10 10 10 10 10 10 11 11 11 11 11 11 11 11 11 11 11 11 11 11 11 11 11 11 11 11 11 11 11 11 11 11 11 11 11 11)
set yyyys = (2014)
set yys =   (  14) 
set hh =    (  00)
set levellist = "levmin=1,levmax=61"
set levellist1 = "levmin=40,levmax=60"
set levellist2 = "levmin=1,levmax=60"
set levellist3 = "levmin=58,levmax=60"
set tstarts = ( 0 )
set tstops  = ( 23 )
#@ ndays = 1

########################################
set fieldextra = /users/osm/opr/abs/
#get cosmo analysis data
set archivedirs = (/store/s83/osm/LA)
set files = (lfff00000000 lfff00010000 lfff00020000 lfff00030000 lfff00040000 lfff00050000 lfff00060000 lfff00070000 lfff00080000 lfff00090000 lfff00100000 lfff00110000 lfff00120000 lfff00130000 lfff00140000 lfff00150000 lfff00160000 lfff00170000 lfff00180000 lfff00190000 lfff00200000 lfff00210000 lfff00220000 lfff00230000)

set wdir = /store/s83/strefalt/phd_wind_hail/data/model/cosmo-2/LA
set LM_LDIR = /users/osm/opr/lib/
set absfieldextra = /oprusers/osm/opr/abs/fieldextra_12.0.1_gnu4.8.2_opt_omp
set extraction = 1
set fieldextra = 1
########################################

#@ n = 0
#while ($n < $ndays)

#@ m = 1
#foreach model ($archivedirs)

    @ d = 1
    foreach day ($dds)
    
    #get cosmo analysis data on fine grid 
    set yyyy=$yyyys
    set yy=$yys
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
&Process in_field = "HSURF",tag="masspoint"/
!&Process in_field = "FR_LAND"/


!---------------------------------------------
! Fields 2: T, U, V, Q -----------------------
!---------------------------------------------
&Process
  in_type = "INCORE"
  out_file="$destination/$yyyy$mm$dd${hh}_<HH>_cosmo2_TQUV" 
  tstart=$tstart, tstop=$tstop, tincr=1 
  in_regrid_target = "masspoint", in_regrid_method = "average,square,0.9"
  out_type="NETCDF"
/
&Process in_field = "HHL", levmin=1, levmax=61 /
&Process in_field = "HSURF",tag="masspoint" /

&Process
  in_file="$destination/lfff<DDHH>0000"
  out_file="$destination/$yyyy$mm$dd${hh}_<HH>_cosmo2_TQUV"
  tstart=$tstart, tstop=$tstop, tincr=1 
  in_regrid_target = "masspoint", in_regrid_method = "average,square,0.9"
  out_type="NETCDF"
/
!---------------------------------------------------------------------------------------
! Define fields to extract:
!---------------------------------------------------------------------------------------
&Process in_field = "T"/
&Process in_field = "P"/
&Process in_field = "QV"/
&Process in_field = "U", regrid=.t./
&Process in_field = "V", regrid=.t./
&Process in_field = "PMSL"/

&Process tmp1_field = "P" /
&Process tmp1_field = "T",voper="intpl_k2p,lnp", voper_lev=700,850 /
&Process tmp1_field = "QV", voper="intpl_k2p,lnp", voper_lev=700,850 /
&Process tmp1_field = "U", poper = "n2geog", voper="intpl_k2p,lnp", voper_lev=700,850  /
&Process tmp1_field = "V", poper = "n2geog", voper="intpl_k2p,lnp", voper_lev=700,850  /
&Process tmp1_field = "PMSL"/



!---------------------------------------------------------------------------------------
! Define output fields:
!---------------------------------------------------------------------------------------
&Process out_field = "T"/
&Process out_field = "QV" /
&Process out_field = "U" /
&Process out_field = "V"  /



EOFNTC

    $absfieldextra $destination/n2.NTC # $destination/logfieldextra1
@ t = $t + 1 
end
        #set ore = ( 00 01 02 03 04 05 06 07 08 09 10 11 12 13 14 15 16 17 18 19 20 21 22 23)
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
    
#    @ m = $m + 1 
#end

#@ n = $n + 1
#end
