#!/bin/tcsh 

# unlimit stacksize (needed to run GNU version of fieldextra)
unlimit stacksize

# to be modified in order to select the wanted day 
set dds =   (  28 )
set yyyys = (2014 )
set yys =   (  14 )
set mms =   (  06 )
set tstops = ( 23 )
set tstarts = ( 0 )
@ ndays = 4
set hh = 00
########################################
set fieldextra = /users/osm/opr/abs/
set archivedirs = (/store/s83/osm/LA)
set files = (lfff00000000 lfff00010000 lfff00020000 lfff00030000 lfff00040000 lfff00050000 lfff00060000 lfff00070000 lfff00080000 lfff00090000 lfff00100000 lfff00110000 lfff00120000 lfff00130000 lfff00140000 lfff00150000 lfff00160000 lfff00170000 lfff00180000 lfff00190000 lfff00200000 lfff00210000 lfff00220000 lfff00230000)
set wdir = /workspace/nisi/
set LM_LDIR = /users/osm/opr/lib/
set absfieldextra = /users/osm/opr/abs/fieldextra
set fieldextra = 1
set extraction = 1
########################################

@ n = 0
while ($n < $ndays)

@ m = 1
foreach model ($archivedirs)

    @ d = 1
    foreach day ($dds)

    @ nhh = 24 * $n
    
    set tmp4 = `/oprusers/osm/bin/addtime -Y $yyyys[1] -M $mms[1] -D $dds[1] -H $hh -T $nhh`
    
    set yyyy=$tmp4[1]
    set mm=$tmp4[2]
    set dd=$tmp4[3]
    set yy=`(echo $tmp4[1] | cut -c3-4)`
    set adir=$archivedirs$yy/$yyyy$mm$dd/fine/ ### CAMBIARE se cosmo-7 o cosmo-2
    #echo $adir

    #set adir=$archivedirs$yy/$yyyy$mm$dd/
    echo "-----------------------------------------------------------------------------"
    echo "archive directory: $adir"
     
    #working directory
    set destination = $wdir/${yyyy}${mm}${dd}_ana/
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
    #cp $wdir/lfff00000000c_coarse ${destination}/lfff00000000c
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
 strict_nl_parsing  = .true.
 verbosity          = "high"
 diagnostic_length  = 110
 soft_memory_limit =  6.0
/

&GlobalResource
 dictionary           = "/oprusers/osm/opr/lib/dictionary_cosmo.txt"
 grib_definition_path = "/oprusers/osm/opr/lib/fieldextra_grib_api_definitions"
/

&GlobalSettings
 default_dictionary = "cosmo",
 default_model_name = "cosmo-2"
/

&ModelSpecification
 model_name         = "cosmo-2"
 earth_axis_large   = 6371229.
 earth_axis_small   = 6371229.
/

!---------------------------------------------------------------------------------------
! Define input and output characteristics, define domain subset:
!---------------------------------------------------------------------------------------

&Process
  in_file  = "$destination/lfff00000000"
  out_type = "INCORE" /
&Process in_field = "HSURF",tag="HSURF"/
&Process in_field = "FR_LAND"/

&Process
  in_file="$destination/lfff<DDHH>0000"
  tstart=$tstart, tstop=$tstop, tincr=1 
  out_file="$destination/$yyyy$mm$dd${hh}_<HH>_cosmo2_HZEROCL.txt"
  out_type="BLK_TABLE",
  !out_type="NETCDF",
  out_grid = "swiss,255500,-159500,964500,479500,1000,1000"
  out_grid_intpl = "linear_fit,square,1.5"/
&Process in_field = "HZEROCL", poper='mask,=-999.0' /
&Process tmp1_field = "HZEROCL", hoper='fill_undef,50' /
&Process out_field = "HZEROCL" /


EOFNTC

    $absfieldextra $destination/n2.NTC # $destination/logfieldextra1
@ t = $t + 1 
end
       rm -f $destination/lfff*
       endif
    
    @ d = $d + 1
    end
    
    @ m = $m + 1 
end

@ n = $n + 1
end
