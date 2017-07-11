#!/bin/tcsh 

unlimit stacksize

#-----------------------------------------------
# SCRIPT TO EXTRACT COSMO-2 DATA
# HOURLY



# to be modified in order to select the wanted day
echo "---------------------------------------------------------------------------"
echo "setting lists of days, months, years (four and two digits)"

set dds         = (30 26 29 25 07 28 31 27 30 25 28 31 27 30 26)
echo $dds
set mms         = (03 10 03 10 11 03 10 03 10 03 10 03 10 03 10)
echo $mms
set yyyys       = (2008 2008 2009 2009 2009 2010 2010 2011 2011 2012 2012 2013 2013 2014 2014)
echo $yyyys
set yys         = (08 08 09 09 09 10 10 11 11 12 12 13 13 14 14) 
echo $yys
set hh          = ( 00)
set tstarts     = ( 0 )
set tstops      = ( 23 )


########################################
set fieldextra = /users/osm/opr/abs/
#get cosmo analysis data
set archivedirs = (/store/s83/osm/LA)
set files = (lfff00000000 lfff00010000 lfff00020000 lfff00030000 lfff00040000 lfff00050000 lfff00060000 lfff00070000 lfff00080000 lfff00090000 lfff00100000 lfff00110000 lfff00120000 lfff00130000 lfff00140000 lfff00150000 lfff00160000 lfff00170000 lfff00180000 lfff00190000 lfff00200000 lfff00210000 lfff00220000 lfff00230000)
#set wdir = /store/s83/strefalt/phd_wind_hail/data/model/cosmo-2/LA
set wdir = /scratch/strefalt/data_for_Helene_20160321
set LM_LDIR = /users/osm/opr/lib/
set absfieldextra = /oprusers/osm/opr/abs/fieldextra_12.0.1_gnu4.8.2_opt_omp
set extraction = 1
set fieldextra = 1
########################################


    @ d = 1
    foreach day ($dds)
    
    #get cosmo analysis data on fine grid 
    set yyyy=$yyyys[$d]
    set yy=$yys[$d]
    set mm=$mms[$d]
    set dd=$dds[$d]
    set adir=$archivedirs$yy/$yyyy$mm$dd/fine
    echo "-----------------------------------------------------------------------------"
    #echo "archive directory of cosmo analysis (fine): $adir"
     
    #working directory for analysis data
    #create if it doesnt exist yet
    set destination = $wdir/${yyyy}${mm}${dd}_ana
    if (! -d $destination) then
          mkdir $destination
        endif
    #echo "working directory of cosmo analysis (fine): $destination"

    #stage whole day and transfer it
    if ($extraction == 1 ) then
      date
      echo "------------"
      echo 1. copying files from here ${adir} to here ${destination}
      echo archive folder content before copying:
      ls -ll ${adir}/laf*
      #stage -w -r $adir
      cp ${adir}/laf* $destination/
      echo destination folder content after copying:
      ls -ll $destination/
      echo "files copied"
      #date

    #rename files
    echo "------------"
    echo "2. renaming files"
    @ nh = 0
    while ($nh < 24)
    echo "----"
    echo nh is $nh
       @ nnh = $nh + 1 
       echo nnh is $nnh
       
        #set tmp3 = `/oprusers/osm/bin/addtime -Y ${yyyy} -M ${mm} -D ${dd} -H ${hh} -T ${nh}`
       
        #if ($nh < 10) then
        #echo tmp3 is $tmp3 "(expected to be" ${yyyy} ${mm} ${dd} 0${nh}")"
        #endif
        #if ($nh >= 10) then
        #echo tmp3 is $tmp3 "(expected to be" ${yyyy} ${mm} ${dd} ${nh}")"
        #endif    	         
        #echo "tmp3 calculated with /oprusers/osm/bin/addtime" 
        
	echo "set filein and fileout:"
	if ($nh < 10) then
	set name="laf"${yyyy}${mm}${dd}0${nh}
	set name2="lfff000"${nh}"0000"
	endif
	if ($nh >= 10) then
	set name="laf"${yyyy}${mm}${dd}${nh}
	set name2="lfff00"${nh}"0000"
	endif
	echo "name is" ${name}
	echo "name2 is" ${name2}
	
	echo ${destination}/${name}
	echo ${destination}/${name2}
	mv ${destination}/${name} ${destination}/${name2}
	#mv ${destination}/laf$tmp3[1]$tmp3[2]$tmp3[3]$tmp3[4] ${destination}/$files[$nnh]
	#mv desitnation/laf2008040100  destination/lfff00000000
       
    @ nh = $nh + 1
    end
    echo "files renamed"
 
    
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
! INCORE fields:
!---------------------------------------------------------------------------------------

&Process
  in_file  = "$destination/lfff00000000"
  out_type = "INCORE" /
&Process in_field = "HSURF",tag="masspoint"/



!----------------------------------------------------
! Fields U_10M, V_10M, FF_10M, DD_10M, W_DIV_H, MCONV
!----------------------------------------------------

&Process
  in_file="$destination/lfff<DDHH>0000"
  tstart=$tstart, tstop=$tstop, tincr=1, tlag = -2,0,1  
  out_file="$destination/$yyyy$mm$dd${hh}_<HH>"
  out_type="NETCDF"
/
!---------------------------------------------------------------------------------------
! Define fields to extract:
!---------------------------------------------------------------------------------------

&Process in_field = "U_10M"/
&Process in_field = "V_10M"/
&Process in_field = "VMAX_10M"/


&Process out_field = "U_10M"/
&Process out_field = "V_10M"/
&Process out_field = "FF_10M"/
&Process out_field = "DD_10M"/
&Process out_field = "VMAX_10M",tag="VMAX_10M"/
&Process out_field = "VMAX_10M",tag = "VMAX_10M_03h", toper="max,-2,0,1,hour"/


EOFNTC

    $absfieldextra $destination/n2.NTC # $destination/logfieldextra1
@ t = $t + 1 
end

        #rm -f $destination/lfff*
        
       endif

    @ d = $d + 1
    end
    
