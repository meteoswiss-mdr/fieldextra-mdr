#!/bin/tcsh 

unlimit stacksize

# to be modified in order to select the wanted day 
#2012-2008
#set dds 	= (  09 23 01 02 10 28 04 20 22 25 26 29 07 12 13 28 03 18 26 27 11 17 26 28 29 01 02 03 05 06 10 11 12 17 23 29 26 06 25 26 30 01 02 04 05 06 07 13 14 16 17 01 02 07 09 21 02 28 30 08 10 22 23 26 29 30 02 03 05 06 11 12 29 30 01 06 07 14 15 13)
#set yyyys 	= (2012 2012 2012 2012 2012 2012 2012 2012 2012 2012 2011 2011 2011 2011 2011 2011 2011 2011 2011 2011 2011 2011 2010 2010 2010 2010 2010 2010 2010 2010 2010 2010 2010 2010 2010 2010 2009 2009 2009 2009 2009 2009 2009 2009 2009 2009 2009 2009 2009 2009 2009 2009 2009 2009 2009 2009 2009 2008 2008 2008 2008 2008 2008 2008 2008 2008 2008 2008 2008 2008 2008 2008 2008 2008 2008 2008 2008 2008 2008 2008)
#set yys 	= (  12 12 12 12 12 12 12 12 12 12 11 11 11 11 11 11 11 11 11 11 11 11 10 10 10 10 10 10 10 10 10 10 10 10 10 10 09 09 09 09 09 09 09 09 09 09 09 09 09 09 09 09 09 09 09 09 09 08 08 08 08 08 08 08 08 08 08 08 08 08 08 08 08 08 08 08 08 08 08 08)
#set mms 	= (  06 06 07 07 07 07 08 08 08 08 05 06 07 07 07 07 08 08 08 08 09 09 05 06 06 07 07 07 07 07 07 07 07 07 07 07 05 06 06 06 06 07 07 07 07 07 07 07 07 07 07 08 08 08 08 08 09 05 05 06 06 06 06 06 06 06 07 07 07 07 07 07 07 07 08 08 08 08 08 09)
set dds 	= (  06)
set mms 	= (  06)
set yyyys 	= (2009) 
set yys 	= (  09)
set levellist 	= "levmin=1,levmax=61"
set levellist1 	= "levmin=1,levmax=60"
set levellist2 	= "levmin=50,levmax=60"
set levellist3 	= "levmin=58,levmax=60"
#set tstops 	= ( 6 12 18 23)
#set tstarts 	= ( 0 7 13 19)
#set tstops 	= ( 1 )
#set tstarts 	= ( 23 )
set tstops 	= ( 23 )
set tstarts 	= ( 0 )
@ ndays 	= 1
set hh 		= 00
set qtl 	= ( 75 )
########################################
set fieldextra 	= /users/osm/opr/abs/
set archivedirs = (/store/s83/osm/LA)
set files 	= (lfff00000000 lfff00010000 lfff00020000 lfff00030000 lfff00040000 lfff00050000 lfff00060000 lfff00070000 lfff00080000 lfff00090000 lfff00100000 lfff00110000 lfff00120000 lfff00130000 lfff00140000 lfff00150000 lfff00160000 lfff00170000 lfff00180000 lfff00190000 lfff00200000 lfff00210000 lfff00220000 lfff00230000)
set wdir 	= /store/s83/strefalt/convectionTI_fields/
set wdir2 	= /store/s83/strefalt/convectionTI_regions/
set LM_LDIR 	= /users/osm/opr/lib/
set absfieldextra = /users/osm/opr/abs/fieldextra_11.0.1_gnu4.5.3_opt_omp
set extraction 	= 1
set fieldextra 	= 1
########################################

@ n = 0
while ($n < $ndays)

@ m = 1
foreach model ($archivedirs)

    @ d = 1
    foreach day ($dds)
    
    set yyyy=$yyyys[$d]
    set mm=$mms[$d]
    set dd=$dds[$d]
    set yy=$yys[$d]
    set adir=$archivedirs$yy/$yyyy$mm$dd/fine
    echo "-----------------------------------------------------------------------------"
    echo "archive directory: $adir"
     
    #working directory
    set destination = $wdir/${yyyy}${mm}${dd}_ana/
    set destination2 = $wdir2/${yyyy}${mm}${dd}_ana/
    if (! -d $destination) then
          mkdir $destination
        endif
   
    echo "working directory: $destination"

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
 strict_nl_parsing  	= .true.
 n_openmp_innerthread 	= 1
 n_openmp_outerthread 	= 1
 verbosity          	= "high"
 diagnostic_length  	= 110
 soft_memory_limit 	= 13
/

&GlobalResource
 dictionary         	= "/oprusers/osm/opr/lib/dictionary_cosmo.txt"
 location_list      	= "/users/strefalt/convection_simona/regions/location_list.txt"
 region_list        	= "/users/strefalt/convection_simona/regions/test_list.txt"
 grib_definition_path 	= "/oprusers/osm/opr/lib/fieldextra_grib_api_definitions"
/

&GlobalSettings
 default_dictionary   	= "cosmo"
 default_model_name 	= "cosmo-2"
 location_to_gridpoint 	= "sn" 
/ 

&ModelSpecification
 model_name         	= "cosmo-2"
 earth_axis_large   	= 6371229.
 earth_axis_small   	= 6371229.
/

!---------------------------------------------------------------------------------------
! Define input and output characteristics, define domain subset:
!---------------------------------------------------------------------------------------

&Process
  in_file  = "$destination/lfff00000000"
  out_type = "INCORE" /
&Process in_field="HSURF", tag="masspoint" /
&Process in_field = "FR_LAND"/


!---------------------------------------------
! Field --------------------------------------
!---------------------------------------------
&Process
  in_type = "INCORE"
  out_file="$destination/$yyyy$mm$dd${hh}_<HH>_cosmo2_MCONV.tmp"
  tstart=$tstart, tstop=$tstop, tincr=1 
  out_type="GRIB1"
  in_grid="masspoint"
/

&Process in_field = "HSURF" /
&Process in_field = "HHL", levmin = 1, levmax = 61 /
&Process in_field = "HFL", levmin = 1, levmax = 60 /

&Process
  in_file="$destination/lfff<DDHH>0000"
  tstart=$tstart, tstop=$tstop, tincr=1 
  out_file="$destination/$yyyy$mm$dd${hh}_<HH>_cosmo2_MCONV.tmp"
  out_type="GRIB1"
  in_grid="masspoint"
/
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

&Process tmp1_field = "MCONV", voper = "integ_sfc2h", voper_lev = 200,500/
&Process tmp1_field = "U", hoper="destagger", voper="intpl_k2h,lnp", voper_lev = 200,500 /
&Process tmp1_field = "V", hoper="destagger", voper="intpl_k2h,lnp", voper_lev = 200,500 /

!---------------------------------------------------------------------------------------
! Define output fields:
!---------------------------------------------------------------------------------------
&Process out_field = "MCONV", tag='MCONV' /
&Process out_field = "U", tag='U' /
&Process out_field = "V", tag='V' /

&Process
  in_file = "$destination/$yyyy$mm$dd${hh}_<HH>_cosmo2_MCONV.tmp"
  out_file = "$destination/$yyyy$mm$dd${hh}_<HH>_cosmo2_MCONV_remove"
  out_type="GRIB1"
  tstart=0, tstop=23, tincr=1 
  imin=180, jmin=70, imax=300, jmax=200 /
  
&Process in_field = "MCONV" /
&Process in_field = "U" /
&Process in_field = "V" /

&Process out_field = "MCONV" /
&Process out_field = "U" /
&Process out_field = "V" /




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
	rm -f $destination/$yyyy$mm$dd${hh}_<HH>_cosmo2_MCONV.tmp
	#rm -f $destination/tmp/*.tmp
        #rm -f $destination/lfff*
        #mv $destination/tmp/NWP* $wdir
        
       endif
    
    @ d = $d + 1
    end
    
    @ m = $m + 1 
end

@ n = $n + 1
end
