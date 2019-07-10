
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/wrf/WRFUserARW.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"

begin 

;  wsd="2015-05-19_00:00:00"
;  sd="2015051900"
;  fcst_hour="00"

  fn_out=start_time+"_f"+fcst_hour
  path="/app/home/tanghao/xuhx/workdir/"+start_time+"/wrfprd"
  wrfin="wrfout_d02_"+wsd
  fn=path+"/"+wrfin+".nc"

  a   = addfile(fn,"r")

  tc2 = wrf_user_getvar(a,"T2",0)
  rh2 = wrf_user_getvar(a,"rh2",0)
  u10 = wrf_user_getvar(a,"U10",0)
  v10 = wrf_user_getvar(a,"V10",0)
  ter = wrf_user_getvar(a,"ter",0)
  psfc= wrf_user_getvar(a,"PSFC",0)
  hfx= wrf_user_getvar(a,"HFX",0)
  qfx= wrf_user_getvar(a,"QFX",0)
  pblh= wrf_user_getvar(a,"PBLH",0)
  rain=wrf_user_getvar(a,"RAINC",0) + wrf_user_getvar(a,"RAINNC",0)
  data = (/ter, psfc, tc2, rh2, u10, v10, hfx, qfx, pblh, rain/)

  data_dim = dimsizes(data)
  station_list="STATION_INI"

  stid=tostring(systemfunc("cat "+station_list+"|awk '{print $1}'  "))
  glat=tofloat(systemfunc("cat "+station_list+"|awk '{print $2}'  "))
  glon=tofloat(systemfunc("cat "+station_list+"|awk '{print $3}'  "))

  nsta = dimsizes(stid)

  opt = True 
  opt@returnInt = False 

  lines=new(nsta+1,"string")
  sta_sfc=new(nsta,"float")


  lines(0) = ""

  do i=0, nsta-1 

      loc  = wrf_user_ll_to_ij(a, glon(i), glat(i), opt)

      inx=tointeger(loc(0))
      jny=tointeger(loc(1))
      rx=loc(0) - inx 
      ry=loc(1) - jny 

      w11=(1.0-rx)*(1.0-ry)
      w12=rx*(1.0-ry)
      w21=(1.0-rx)*ry
      w22=rx*ry

      lines(i+1) = sd+"0000 "+stid(i) + " " + \
             sprintf("%10.2f",glon(i)) + " " + \
             sprintf("%10.2f",glat(i))  

      do j=0, data_dim(0)-1

          f11=data(j, jny-1, inx)
          f12=data(j, jny-1, inx+1)
          f21=data(j, jny, inx)
          f22=data(j, jny, inx+1)
          sta_sfc(j) = f11*w11+f12*w12+f21*w21+f22*w22      

          lines(i+1) = lines(i+1) + " " + sprintf("%10.2f",sta_sfc(j)) 

      end do

  end do

  asciiwrite(fn_out+".txt",lines)

end
