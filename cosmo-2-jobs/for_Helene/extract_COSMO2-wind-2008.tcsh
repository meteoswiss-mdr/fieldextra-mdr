#!/bin/tcsh 

unlimit stacksize

#-----------------------------------------------
# SCRIPT TO EXTRACT COSMO-2 DATA



# to be modified in order to select the wanted day 

#set dates   = ( 20080325 20080326 20080327 20080328 20080329 20080330 20080331 20080401 20080402 20080403 20080404 20080405 20080406 20080407 20080408 20080409 20080410 20080411 20080412 20080413 20080414 20080415 20080416 20080417 20080418 20080419 20080420 20080421 20080422 20080423 20080424 20080425 20080426 20080427 20080428 20080429 20080430 20080501 20080502 20080503 20080504 20080505 20080506 20080507 20080508 20080509 20080510 20080511 20080512 20080513 20080514 20080515 20080516 20080517 20080518 20080519 20080520 20080521 20080522 20080523 20080524 20080525 20080526 20080527 20080528 20080529 20080530 20080531 20080601 20080602 20080603 20080604 20080605 20080606 20080607 20080608 20080609 20080610 20080611 20080612 20080613 20080614 20080615 20080616 20080617 20080618 20080619 20080620 20080621 20080622 20080623 20080624 20080625 20080626 20080627 20080628 20080629 20080630 20080701 20080702 20080703 20080704 20080705 20080706 20080707 20080708 20080709 20080710 20080711 20080712 20080713 20080714 20080715 20080716 20080717 20080718 20080719 20080720 20080721 20080722 20080723 20080724 20080725 20080726 20080727 20080728 20080729 20080730 20080731 20080801 20080802 20080803 20080804 20080805 20080806 20080807 20080808 20080809 20080810 20080811 20080812 20080813 20080814 20080815 20080816 20080817 20080818 20080819 20080820 20080821 20080822 20080823 20080824 20080825 20080826 20080827 20080828 20080829 20080830 20080831 20080901 20080902 20080903 20080904 20080905 20080906 20080907 20080908 20080909 20080910 20080911 20080912 20080913 20080914 20080915 20080916 20080917 20080918 20080919 20080920 20080921 20080922 20080923 20080924 20080925 20080926 20080927 20080928 20080929 20080930 20081001 20081002 20081003 20081004 20081005 20081006 20081007 20081008 20081009 20081010 20081011 20081012 20081013 20081014 20081015 20081016 20081017 20081018 20081019 20081020 20081021 20081022 20081023 20081024 20081025 20081026 20081027 20081028 20081029 20081030 20081031 20081101 20081102 20081103 20081104 20081105 20081106 20081107 20081108 20081109 20081110 20081111 20081112 20081113 20081114 20081115 20081116 20081117 20081118 20081119 20081120 20081121 20081122 20081123 20081124 20081125 20081126 20081127 20081128 20081129 20081130 20081201 20081202 20081203 20081204 20081205 20081206 20081207 20081208 20081209 20081210 20081211 20081212 20081213 20081214 20081215 20081216 20081217 20081218 20081219 20081220 20081221 20081222 20081223 20081224 20081225 20081226 20081227 20081228 20081229 20081230 20081231)  
set dates = ( 20080101 20080102 20080103 20080104 20080105 20080106 20080107 20080108 20080109 20080110 20080111  20080112 20080113 20080114 20080115 20080116 20080117 20080118 20080119 20080120 20080121 20080122 20080123 20080124 20080125 20080126 20080127 20080128 20080129 20080130 20080131 20080201 20080202 20080203 20080204 20080205 20080206 20080207 20080208 20080209 20080210 20080211 20080212 20080213 20080214 20080215 20080216 20080217 20080218 20080219 20080220 20080221 20080222 20080223 20080224 20080225 20080226 20080227 20080228 20080229 20080301 20080302 20080303 20080304 20080305 20080306 20080307 20080308 20080309 20080310 20080311 20080312 20080313 20080314 20080315 20080316 20080317 20080318 20080319 20080320 20080321 20080322 20080323 20080324)
#echo $dates
set hh      = ( 00)
set levellist = "levmin=1,levmax=61"
set tstarts = ( 0 )
set tstops  = ( 23 )
set modeltype = fine

########################################
set fieldextra = /users/osm/opr/abs/
set files = (lfff00000000 lfff00010000 lfff00020000 lfff00030000 lfff00040000 lfff00050000 lfff00060000 lfff00070000 lfff00080000 lfff00090000 lfff00100000 lfff00110000 lfff00120000 lfff00130000 lfff00140000 lfff00150000 lfff00160000 lfff00170000 lfff00180000 lfff00190000 lfff00200000 lfff00210000 lfff00220000 lfff00230000)
set wdir = /scratch/strefalt/data_for_Helene_20151125
set LM_LDIR = /users/osm/opr/lib/
set absfieldextra = /oprusers/osm/opr/abs/fieldextra_12.0.1_gnu4.8.2_opt_omp
set extraction = 1
set fieldextra = 1
########################################


    @ d = 1
    foreach date ($dates)
    
    #get cosmo analysis data on fine grid 
    set date = $dates[$d]  #20080101
    set yyyy = `echo ${date} | awk '{print substr($date,0,4)}'` #2008
    set yy   = `echo ${date} | awk '{print substr($date,3,2)}'` #08
    set mm   = `echo ${date} | awk '{print substr($date,5,2)}'` #01
    set dd   = `echo ${date} | awk '{print substr($date,7,2)}'` #01

    echo ""
    echo ""
    echo ""
    echo $date
    

     
    #working directory for analysis data
    #create if it doesnt exist yet
    set destination = $wdir/${date}_ana
    if (! -d $destination) then
          mkdir $destination
        endif
	
    echo "-----------------------------------------------------------------------------"
    echo "working directory of cosmo analysis (fine): $destination"
    
    set adir = /store/s83/osm/LA$yy/$date/$modeltype 
    echo "archive directory of cosmo analysis (fine): $adir"

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
        
       endif

    @ d = $d + 1
    end
    

@ n = $n + 1
end
