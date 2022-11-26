# metaMIS部署指南

### 登陆页面

#### html

login.html

#### lua

/ordsys/API/login

### 菜单主页

#### html

home.html

#### lua

/ordsys/API/getmenu

"select d.f_authid,d.f_authname,d.f_authurl,d.f_requestmethod,d.f_desc

 from t_user as a 

left join t_user_role as b on a.f_id = b.f_user_id 

left join t_role_auth as c on b.f_role_id = c.f_role_id 

left join t_auth as d on c.f_auth_id = d.f_authid where a.f_id = '" .. userId .. "';"

#### t_user用户

f_id                38

f_uname        gptest 

#### t_auth可授权程序

f_authid            2 

f_authname    精卓-报关单

f_authurl

f_requestmethod

f_desc

#### t_role角色

f_id        20

f_role    role-gp-cd

#### t_user_role用户角色授权

f_user_id        38

f_role_id        20

#### t_role_auth角色程序授权

### odata service

/IWFND/MAINT_SERVICE
