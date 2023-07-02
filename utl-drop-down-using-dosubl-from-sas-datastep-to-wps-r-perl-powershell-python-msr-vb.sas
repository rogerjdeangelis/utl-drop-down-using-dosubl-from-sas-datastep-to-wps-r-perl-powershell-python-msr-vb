%let pgm=utl-drop-down-using-dosubl-from-sas-datastep-to-wps-r-perl-powershell-python-msr-vb;

Dropping down to mutiple languages from within a SAS datastep

github
https://tinyurl.com/26kf6e6z
https://github.com/rogerjdeangelis/utl-drop-down-using-dosubl-from-sas-datastep-to-wps-r-perl-powershell-python-msr-vb

 You need three level quoting in your drop downs to other languages

 '  Single quote
 "  Double quote
 `  Backtic quote  (delayed resolution using ` after dosubl and utl_submit execution)

 New utl_submit_wps64 macro on end

 Just two changes                                             /*---- adds third quote level                -----*/
  1. added if index(cmd,"`") then cmd=tranwrd(cmd,"`","27"x); /*---- delayed map of bactic to single quote -----*/
  2. made sure all my utl_submit_* use only double quotes
  3. Although not shown here all drop downs can return a SAS macro variable, so you can create dropdown functions.

 Having three levels of quotes should expand the integration of SAS dtastep with all other languages

 I am using drop downs to wps 'proc r' and 'proc python' but it should work with all other
 languages dropdowns from SAS datastep

    utl_sumnit_wps64     WPS
    utl_sumnit_pl64      PERL
    utl_sumnit_ps64      POWERSHELL
    utl_sumnit_py64_311  PYTHON
    utl_sumnit_py64_27   PYTHON
    utl_sumnit_r64       R
    utl_sumnit_r64       MSR          Microsoft R
    utl_sumnit_vb64      VB

 SAS NEEDS TO SPEEDUP DOSUBL AND DEVELOPERS NEED TO SPEEDUP SQL INTERFACES WITH NATIVE LANGUAGE.
 WIN32 API to share storage is well documented in Python, having problem sharing storage amoung languages

 /*                          _
  __ _  __ _  ___ _ __   __| | __ _
 / _` |/ _` |/ _ \ `_ \ / _` |/ _` |
| (_| | (_| |  __/ | | | (_| | (_| |
 \__,_|\__, |\___|_| |_|\__,_|\__,_|
       |___/
*/
 Agenda (aslo works with languages other than WPS will post)

  WPS PROC R

    1  Simple three level quoting with dosubl and passing sas macro variables to sql

    2  Three level quotes & passing R variables to sql

  WPS Proc Python

    3  Simple three level quoting with dosubl nd passing sas macro variables to sql

    4  Three level quotes & passing Python variables to sql

Problems

     Which girls have signed up for shop in Mrs Bloom homeroom
     Which boys have signed up for typing in Mrs Bloom homeroom

     Create datasets Female and Male for students taking math

/*               _                   _   _
  _____  ___ __ | | __ _ _ __   __ _| |_(_) ___  _ __  ___
 / _ \ \/ / `_ \| |/ _` | `_ \ / _` | __| |/ _ \| `_ \/ __|
|  __/>  <| |_) | | (_| | | | | (_| | |_| | (_) | | | \__ \
 \___/_/\_\ .__/|_|\__,_|_| |_|\__,_|\__|_|\___/|_| |_|___/
          |_|
*/

 A. R

     1.  R Simple three level quoting with dosubl and passing sas macro variables to sql

           call symputx('course',course);
           call symputx('sex'   ,sex);

           rc=dosubl('                       /*---- cannot use single quote again                            ----*/

            %utl_submit_wps64x("             /*---- cannot use double  quote again                           ----*/

              libname sd1 `d:\sd1`;          /* delayed chage of backtic to single quote                     ----*/
              proc r;
              export data=sd1.have r=have ;
              submit;
                 library(sqldf);

                   out<-sqldf(`                   /*---- backtic mapped to single quote                      ----*/
                                                  /*---- this hides the single quote from dosubl             ----*/

                   select                         /*---- we can freely use backtic noe                       ----*/
                     \`Mrs Bloom\`  as HOMEROOM
                    ,NAME
                    ,SEX
                    ,AGE
                    ,COURSE
                   from
                     have
                   where
                         SEX    = \`&sex\`
                     and COURSE = \`&course\`
                   `);
             print(out);
             endsubmit;
             import data=sd1.&sex r=out;
             run;quit;
             %let status=&syserr;
            ");
           ');

     2.  Three level quotes & passing R variables to sql

        Problem create datasets F and M for students taking math
        R variables SEX and COURSE are passed to sqldf
                                                                                                             ----*/
        call symputx('course',course);
        call symputx('sex'   ,sex);

        rc=dosubl('                   /*---- cannot use single quotse again                                  ----*/

         %utl_submit_wps64x("         /*---- cannot use double  quotes again                                 ----*/
            %put &=squote;
            libname sd1 `d:\sd1`;
            proc r;
            export data=sd1.have r=have ;
            submit;
            library(sqldf);
            MATH <- sQuote(`MATH`);   /*---- Content of MATH has embeded single quote                        ----*/
                                      /* Variable math contains embetted quotes 'MATH'                       ----*/
                                      /* We pass the R variable value to SQL                                 ----*/

            SEX  <- sQuote(`&SEX`);   /*---- Content of SEX  has embeded single quote                        ----*/

            want<-sqldf(paste(`select NAME ,SEX,  COURSE  from have where COURSE = `, MATH, `and SEX=`,SEX));

            want;
            endsubmit;
            import data=sd1.&sex r=want;
            ");
            %let status=&syserr;
        ');

 B. Python

     3.  Simple three level quoting with dosubl & passing sas macro variables to sql  /*---- slowplease fix ----*/

          call symputx('course',course);
          call symputx('sex'   ,sex);

          rc=dosubl('                                  /*---- cannot use single quote again                  ----*/

            %utl_submit_wps64x("                       /*---- cannot use double  quote again                 ----*/

              libname sd1 `d:\sd1`;
              proc python;
                export data=sd1.have python=have;
                submit;

                from os import path;
                import pandas as pd;
                import numpy as np;
                from pandasql import sqldf;

                mysql = lambda q: sqldf(q, globals()); /*---- need all this stuff because, unlike R python,  ----*/
                from pandasql import PandaSQL;         /*---- does not provide simple functions like log,    ----*/
                pdsql = PandaSQL(persist=True);        /*---- standrd deviation as part of SQL need dll      ----*/
                sqlite3conn = next(pdsql.conn.gen).connection.connection;
                sqlite3conn.enable_load_extension(True);
                sqlite3conn.load_extension(`c:/temp/libsqlitefunctions.dll`);
                mysql = lambda q: sqldf(q, globals());                        /*---- end stuff               ----*/

                out = pdsql(```
                      select                           /*---- triple backtic mappped to three single quotes  ----*/
                          `Mrs Bloom` as HOMEROOM      /*---- single backtic mappped to single quote         ----*/
                          ,*
                      from
                           have
                      where
                              trim(course) = `&course` /
                          and sex          = `&sex`
                      ```);
                print(out);
                endsubmit;
                import data=sd1.&sex python=out;
            ");
             %let status=&syserr;
           ');

         if symgetn('status')=0 then status="SQL SUCESSFUL";
         else                        status="SQL FAILED   ";

     4  Three three level quotes & passing Python variables to sql /*---- slow please fix, like sas did      ----*/

          call symputx('course',course);
          call symputx('sex'   ,sex);

          rc=dosubl('                                  /*---- cannot use single quote again                  ----*/

            %utl_submit_wps64x("                       /*---- cannot use double  quote again                 ----*/

              libname sd1 `d:\sd1`;
              proc python;
                export data=sd1.have python=have;
                submit;

                from os import path;
                import pandas as pd;
                import numpy as np;
                from pandasql import sqldf;

                mysql = lambda q: sqldf(q, globals()); /*---- need all this stuff because, unlike R python,  ----*/
                from pandasql import PandaSQL;         /*---- does not provide simple functions like log,    ----*/
                pdsql = PandaSQL(persist=True);        /*---- standrd deviation as part of SQL need dll      ----*/
                sqlite3conn = next(pdsql.conn.gen).connection.connection;
                sqlite3conn.enable_load_extension(True);
                sqlite3conn.load_extension(`c:/temp/libsqlitefunctions.dll`);
                mysql = lambda q: sqldf(q, globals());                        /*---- end stuff               ----*/

         courseval = `&course`;
         sexval    = `&sex`;
         q = ```
               select
                    *
               from
                    have
               where
                    sex = `&sex` and                          /*---- quoted sas macro variable directly      ----*/
                       trim(course) = ``` + repr(courseval) ; /*---- passing a pytho n variable              ----*/
         while `  ` in q: q = q.replace(`  `, ` `);
         print(q);
         out = pdsql(q);
         print(out);
         endsubmit;
         import data=sd1.&sex python=out;
     ");
      %let status=&syserr;
    ');

  if symgetn('status')=0 then status="SQL SUCESSFUL";
  else                        status="SQL FAILED   ";

run;quit;

/*                              _
  _____  ____ _ _ __ ___  _ __ | | ___  ___
 / _ \ \/ / _` | `_ ` _ \| `_ \| |/ _ \/ __|
|  __/>  < (_| | | | | | | |_) | |  __/\__ \
 \___/_/\_\__,_|_| |_| |_| .__/|_|\___||___/
                         |_|
 _                   _
(_)_ __  _ __  _   _| |_
| | `_ \| `_ \| | | | __|
| | | | | |_) | |_| | |_
|_|_| |_| .__/ \__,_|\__|
        |_|
*/

options validvarname=upcase;

libname sd1 "d:/sd1";

Data sd1.meta;
 course='TYPING';sex='M';output;
 course='SHOP  ';sex='F';output;
run;quit;

libname sd1 "d:/sd1";
data sd1.have ;
   set sashelp.class(keep=name sex age);
   if uniform(12575)<.33      then course='TYPING';
   else if uniform(15945)<.85 then course='SHOP  ';
   else                            course='MATH  ';
run;quit;

proc sort data=sd1.have ;
by sex course;
run;quit;

/**************************************************************************************************************************/
/*                                                                              |                                         */
/*  SD1.HAVE                            SD1.META                                | RULES (THree OUTPUT DATASETS )          */
/*                                                                              |                                         */
/*  Mrs Bloom Homeroom Class            We are interested in males              | SD1.F                                   */
/*                                      taking typing and females taking shop   |                                         */
/*                                      in Mrs Bloom homeroom class             |                                         */
/*                                                                              |  FEMALES TAKING SHOP CLASS              */
/*   SD1.HAVE total obs=19              SD1.META total obs=2                    |                                         */
/*                                                                              |   HOMEROOM    NAME   SEX AGE    COURSE  */
/*   Name       Sex    Age    course     course    sex                          |                                         */
/*                                                                              |   Mrs Bloom  Janet    F   15     SHOP   */
/*   Alice       F      13    MATH       TYPING     M                           |   Mrs Bloom  Judy     F   14     SHOP   */
/*   Carol       F      14    MATH       SHOP       F                           |   Mrs Bloom  Louise   F   12     SHOP   */
/*                                                                              |   Mrs Bloom  Mary     F   15     SHOP   */
                                                                                |                                         */
/*   Janet       F      15    SHOP                                              |                                         */
/*   Judy        F      14    SHOP                                              |  MALES TAKING TYPING COURSES            */
/*   Louise      F      12    SHOP                                              |                                         */
/*   Mary        F      15    SHOP                                              |   Mrs Bloom  Henry    M   14    TYPING  */
/*                                                                              |   Mrs Bloom  James    M   12    TYPING  */
/*   Barbara     F      13    TYPING                                            |                                         */
/*   Jane        F      12    TYPING                                            | LOG FILE                                */
/*   Joyce       F      11    TYPING                                            |                                         */
/*   Alfred      M      14    MATH                                              | WORK.LOG total obs=2                    */
/*   Ronald      M      15    MATH                                              | Obs  COURSE    SEX    RC      STATUS    */
/*   Jeffrey     M      13    SHOP                                              |                                         */
/*   John        M      12    SHOP                                              |  1   TYPING     M      0    SUCCESSFULL */
/*   Philip      M      16    SHOP                                              |  2   SHOP       F      0    SUCCESSFULL */
/*   Robert      M      12    SHOP                                              |                                         */
/*   Thomas      M      11    SHOP                                              |                                         */
/*   William     M      15    SHOP                                              |                                         */
/*                                                                              |                                         */
/*   Henry       M      14    TYPING                                            |                                         */
/*   James       M      12    TYPING                                            |                                         */
/*                                                                              |                                         */
/**************************************************************************************************************************/


/*              _                 _        _   _                     _                _                     _   _
/ |  _ __   ___(_)_ __ ___  _ __ | | ___  | |_| |__  _ __ ___  ___  | | _____   _____| |   __ _ _   _  ___ | |_(_)_ __   __ _
| | | `__| / __| | `_ ` _ \| `_ \| |/ _ \ | __| `_ \| `__/ _ \/ _ \ | |/ _ \ \ / / _ \ |  / _` | | | |/ _ \| __| | `_ \ / _` |
| | | |    \__ \ | | | | | | |_) | |  __/ | |_| | | | | |  __/  __/ | |  __/\ V /  __/ | | (_| | |_| | (_) | |_| | | | | (_| |
|_| |_|    |___/_|_| |_| |_| .__/|_|\___|  \__|_| |_|_|  \___|\___| |_|\___| \_/ \___|_|  \__, |\__,_|\___/ \__|_|_| |_|\__, |
                           |_|                                                               |_|                        |___/
*/

 proc datasets lib=sd1 nodetails nolist;
  delete m f;
 run;quit;

 %symdel course sex status / nowarn;

 data log;

   set sd1.meta;

   call symputx('course',course);
   call symputx('sex'   ,sex);

  rc=dosubl('
    %utl_submit_wps64x("
    libname sd1 `d:\sd1`;
    proc r;
    export data=sd1.have r=have ;
    submit;
    library(sqldf);
      out<-sqldf(`
      select
        \`Mrs Bloom\`  as HOMEROOM
       ,NAME
       ,SEX
       ,AGE
       ,COURSE
      from
        have
      where
            SEX    = \`&sex\`
        and COURSE = \`&course\`
      `);
   print(out);
   endsubmit;
   import data=sd1.&sex r=out;
   run;quit;
   %let status=&syserr;
   ");
  ');

   if symgetn('status')=0 then status="SUCCESSFULL";
   else status = "FAILED";

 run;quit;

/*           _               _
  ___  _   _| |_ _ __  _   _| |_
 / _ \| | | | __| `_ \| | | | __|
| (_) | |_| | |_| |_) | |_| | |_
 \___/ \__,_|\__| .__/ \__,_|\__|
                |_|
*/

/**************************************************************************************************************************/
/*                                                                                                                        */
/*  SD1.F total obs=4 28JUN2023:13:34:05                                                                                  */
/*                                                                                                                        */
/*  Obs    HOMEROOM      NAME     SEX    AGE    COURSE                                                                    */
/*                                                                                                                        */
/*   1     Mrs Bloom    Janet      F      15     SHOP                                                                     */
/*   2     Mrs Bloom    Judy       F      14     SHOP                                                                     */
/*   3     Mrs Bloom    Louise     F      12     SHOP                                                                     */
/*   4     Mrs Bloom    Mary       F      15     SHOP                                                                     */
/*                                                                                                                        */
/*                                                                                                                        */
/*  SD1.M total obs=2 28JUN2023:13:33:42                                                                                  */
/*                                                                                                                        */
/*   Obs    HOMEROOM     NAME     SEX    AGE    COURSE                                                                    */
/*                                                                                                                        */
/*    1     Mrs Bloom    Henry     M      14    TYPING                                                                    */
/*    2     Mrs Bloom    James     M      12    TYPING                                                                    */
/*                                                                                                                        */
/*                                                                                                                        */
/*                                                                                                                        */
/*  WORK.LOG total obs=2                                                                                                  */
/*                                                                                                                        */
/*  Obs  COURSE    SEX    RC      STATUS                                                                                  */
/*                                                                                                                        */
/*   1   TYPING     M      0    SUCCESSFULL                                                                               */
/*   2   SHOP       F      0    SUCCESSFULL                                                                               */
/*                                                                                                                        */
/**************************************************************************************************************************/

/*___           _   _                                       _               ___                                                           _     _  __
|___ \   _ __  | |_| |__  _ __ ___  ___    __ _ _   _  ___ | |_ ___  ___   ( _ )    _ __   __ _ ___ ___    __ _ _ __ __ _ ___   ___  __ _| | __| |/ _|
  __) | | `__| | __| `_ \| `__/ _ \/ _ \  / _` | | | |/ _ \| __/ _ \/ __|  / _ \/\ | `_ \ / _` / __/ __|  / _` | `__/ _` / __| / __|/ _` | |/ _` | |_
 / __/  | |    | |_| | | | | |  __/  __/ | (_| | |_| | (_) | ||  __/\__ \ | (_>  < | |_) | (_| \__ \__ \ | (_| | | | (_| \__ \ \__ \ (_| | | (_| |  _|
|_____| |_|     \__|_| |_|_|  \___|\___|  \__, |\__,_|\___/ \__\___||___/  \___/\/ | .__/ \__,_|___/___/  \__,_|_|  \__, |___/ |___/\__, |_|\__,_|_|
                                             |_|                                   |_|                              |___/              |_|
*/

 proc datasets lib=sd1 nodetails nolist;
  delete want;
 run;quit;

 %symdel course sex status / nowarn;

 data log;

   set sd1.meta;

   call symputx('course',course);
   call symputx('sex'   ,sex);

  rc=dosubl('
    %utl_submit_wps64x("
       %put &=squote;
       libname sd1 `d:\sd1`;
       proc r;
       export data=sd1.have r=have ;
       submit;
       library(sqldf);
       MATH <- sQuote(`MATH`);
       SEX  <- sQuote(`&SEX`);
       want<-sqldf(paste(`select NAME ,SEX,  COURSE  from have where COURSE = `, MATH, `and SEX=`,SEX));
       want;
       endsubmit;
       import data=sd1.&sex r=want;
       ");
       %let status=&syserr;
  ');
  if symgetn('status')=0 then status="SQL SUCESSFUL";
  else                        status="SQL FAILED";

  run;quit;

/*           _               _
  ___  _   _| |_ _ __  _   _| |_
 / _ \| | | | __| `_ \| | | | __|
| (_) | |_| | |_| |_) | |_| | |_
 \___/ \__,_|\__| .__/ \__,_|\__|
                |_|
*/

/**************************************************************************************************************************/
/*                                                                                                                        */
/*  SD1.F total obs=2 29JUN2023:09:12:28     LOG total obs=2 29JUN2023:09:12:53                                           */
/*                                                                                                                        */
/*  Obs    NAME     SEX    COURSE            Obs    COURSE    SEX    RC       STATUS                                      */
/*                                                                                                                        */
/*   1     Alice     F      MATH              1     TYPING     M      0    SQL SUCESSFUL                                  */
/*   2     Carol     F      MATH              2     SHOP       F      0    SQL SUCESSFUL                                  */
/*                                                                                                                        */
/*                                                                                                                        */
/*                                                                                                                        */
/*  SD1.M total obs=2 29JUN2023:09:12:40                                                                                  */
/*                                                                                                                        */
/*  Obs     NAME     SEX    COURSE                                                                                        */
/*                                                                                                                        */
/*   1     Alfred     M      MATH                                                                                         */
/*   2     Ronald     M      MATH                                                                                         */
/*                                                                                                                        */
/**************************************************************************************************************************/

/*____                 _____   _                _                     _              _            _                 _     _
|___ /   _ __  _   _| |___ /  | | _____   _____| |   __ _ _   _  ___ | |_ ___  ___  (_)_ __    __| | ___  ___ _   _| |__ | |
  |_ \  | `_ \| | | |   |_ \  | |/ _ \ \ / / _ \ |  / _` | | | |/ _ \| __/ _ \/ __| | | `_ \  / _` |/ _ \/ __| | | | `_ \| |
 ___) | | |_) | |_| |  ___) | | |  __/\ V /  __/ | | (_| | |_| | (_) | ||  __/\__ \ | | | | || (_| | (_) \__ \ |_| | |_) | |
|____/  | .__/ \__, | |____/  |_|\___| \_/ \___|_|  \__, |\__,_|\___/ \__\___||___/ |_|_| |_| \__,_|\___/|___/\__,_|_.__/|_|
        |_|    |___/                                   |_|
*/

 proc datasets lib=sd1 nodetails nolist;
  delete f m;
 run;quit;

 %symdel course sex status / nowarn;

 data log;

   set sd1.meta;

   call symputx('course',course);
   call symputx('sex'   ,sex);

  rc=dosubl('
     %utl_submit_wps64x("
       libname sd1 `d:\sd1`;
       proc python;
         export data=sd1.have python=have;
         submit;
         from os import path;
         import pandas as pd;
         import numpy as np;
         import pandas as pd;
         from pandasql import sqldf;
         mysql = lambda q: sqldf(q, globals());
         from pandasql import PandaSQL;
         pdsql = PandaSQL(persist=True);
         sqlite3conn = next(pdsql.conn.gen).connection.connection;
         sqlite3conn.enable_load_extension(True);
         sqlite3conn.load_extension(`c:/temp/libsqlitefunctions.dll`);
         mysql = lambda q: sqldf(q, globals());
         out = pdsql(```
               select
                   `Mrs Bloom` as HOMEROOM
                   ,*
               from
                    have
               where
                       trim(course) = `&course`
                   and sex          = `&sex`
               ```);
         print(out);
         endsubmit;
         import data=sd1.&sex python=out;
     ");
      %let status=&syserr;
    ');

  if symgetn('status')=0 then status="SQL SUCESSFUL";
  else                        status="SQL FAILED   ";

run;quit;         sd1.meta

/*           _               _
  ___  _   _| |_ _ __  _   _| |_
 / _ \| | | | __| `_ \| | | | __|
| (_) | |_| | |_| |_) | |_| | |_
 \___/ \__,_|\__| .__/ \__,_|\__|
                |_|
*/

/**************************************************************************************************************************/
/*                                                                                                                        */
/* SD1.F total obs=4 29JUN2023:13:32:32                    INPUT SD1.META total obs=2 30JUN2023:09:19:15                  */
/*                                                                                                                        */
/*  Obs    HOMEROOM      NAME     SEX    AGE    COURSE      Obs    COURSE    SEX                                          */
/*                                                                                                                        */
/*   1     Mrs Bloom    Janet      F      15     SHOP        1     TYPING     M                                           */
/*   2     Mrs Bloom    Judy       F      14     SHOP        2     SHOP       F                                           */
/*   3     Mrs Bloom    Louise     F      12     SHOP                                                                     */
/*                                                                                                                        */
/*                                                                                                                        */
/*                                                                                                                        */
/* SD1.M total obs=2 29JUN2023:13:33:03                                                                                   */
/*                                                                                                                        */
/*  Obs    HOMEROOM     NAME     SEX    AGE    COURSE                                                                     */
/*                                                                                                                        */
/*   1     Mrs Bloom    Henry     M      14    TYPING                                                                     */
/*   2     Mrs Bloom    James     M      12    TYPING                                                                     */
/*                                                                                                                        */
/*                                                                                                                        */
/*                                                                                                                        */
/* LOG total obs=2 29 JUN2023:13:33:25                                                                                     */
/*                                                                                                                        */
/*                                                                                                                        */
/*  Obs    COURSE    SEX    RC       STATUS                                                                               */
/*                                                                                                                        */
/*   1     TYPING     M      0    SQL SUCESSFUL                                                                           */
/*   2     SHOP       F      0    SQL SUCESSFUL                                                                           */
/*                                                                                                                        */
/**************************************************************************************************************************/
 _  _     _____   _       _                     _                                                 _                     _   
| || |   |___ /  | |_   _| |   __ _ _   _  ___ | |_ ___  ___   _ __  _   _ __   ____ _ _ __ ___  | |_ _ __    ___  __ _| |  
| || |_    |_ \  | \ \ / / |  / _` | | | |/ _ \| __/ _ \/ __| | `_ \| | | |\ \ / / _` | `__/ __| | __| `_ \  / __|/ _` | |  
|__   _|  ___) | | |\ V /| | | (_| | |_| | (_) | ||  __/\__ \ | |_) | |_| | \ V / (_| | |  \__ \ | |_| |_) | \__ \ (_| | |  
   |_|   |____/  |_| \_/ |_|  \__, |\__,_|\___/ \__\___||___/ | .__/ \__, |  \_/ \__,_|_|  |___/  \__| .__/  |___/\__, |_|  
                                 |_|                          |_|    |___/                           |_|             |_|                                                                                                                              
 proc datasets lib=sd1 nodetails nolist;
  delete f m;
 run;quit;

 %symdel course sex status / nowarn;

 data log;

   set sd1.meta;

   call symputx('course',course);
   call symputx('sex'   ,sex);

  rc=dosubl('
     %utl_submit_wps64x("
       libname sd1 `d:\sd1`;
       proc python;
         export data=sd1.have python=have;
         submit;
         from os import path;
         import pandas as pd;
         import numpy as np;
         import pandas as pd;
         from pandasql import sqldf;
         mysql = lambda q: sqldf(q, globals());
         from pandasql import PandaSQL;
         pdsql = PandaSQL(persist=True);
         sqlite3conn = next(pdsql.conn.gen).connection.connection;
         sqlite3conn.enable_load_extension(True);
         sqlite3conn.load_extension(`c:/temp/libsqlitefunctions.dll`);
         mysql = lambda q: sqldf(q, globals());
         courseval = `&course`;
         sexval    = `&sex`;
         q = ```
               select
                    *
               from
                    have
               where
                    sex = `&sex` and
                       trim(course) = ``` + repr(courseval) ;
         while `  ` in q: q = q.replace(`  `, ` `);
         print(q);
         out = pdsql(q);
         print(out);
         endsubmit;
         import data=sd1.&sex python=out;
     ");
      %let status=&syserr;
    ');

  if symgetn('status')=0 then status="SQL SUCESSFUL";
  else                        status="SQL FAILED   ";

run;quit;


/*           _               _
  ___  _   _| |_ _ __  _   _| |_
 / _ \| | | | __| `_ \| | | | __|
| (_) | |_| | |_| |_) | |_| | |_
 \___/ \__,_|\__| .__/ \__,_|\__|
                |_|
*/

/**************************************************************************************************************************/
/*                                                                                                                        */
/* SD1.F total obs=4 29JUN2023:13:32:32                    INPUT SD1.META total obs=2 30JUN2023:09:19:15                  */
/*                                                                                                                        */
/*  Obs    HOMEROOM      NAME     SEX    AGE    COURSE      Obs    COURSE    SEX                                          */
/*                                                                                                                        */
/*   1     Mrs Bloom    Janet      F      15     SHOP        1     TYPING     M                                           */
/*   2     Mrs Bloom    Judy       F      14     SHOP        2     SHOP       F                                           */
/*   3     Mrs Bloom    Louise     F      12     SHOP                                                                     */
/*                                                                                                                        */
/*                                                                                                                        */
/*                                                                                                                        */
/* SD1.M total obs=2 29JUN2023:13:33:03                                                                                   */
/*                                                                                                                        */
/*  Obs    HOMEROOM     NAME     SEX    AGE    COURSE                                                                     */
/*                                                                                                                        */
/*   1     Mrs Bloom    Henry     M      14    TYPING                                                                     */
/*   2     Mrs Bloom    James     M      12    TYPING                                                                     */
/*                                                                                                                        */
/*                                                                                                                        */
/*                                                                                                                        */
/* LOG total obs=2 29 JUN2023:13:33:25                                                                                     */
/*                                                                                                                        */
/*                                                                                                                        */
/*  Obs    COURSE    SEX    RC       STATUS                                                                               */
/*                                                                                                                        */
/*   1     TYPING     M      0    SQL SUCESSFUL                                                                           */
/*   2     SHOP       F      0    SQL SUCESSFUL                                                                           */
/*                                                                                                                        */
/**************************************************************************************************************************/

/*     _   _               _               _ _                         __   _  _
 _   _| |_| |    ___ _   _| |__  _ __ ___ (_) |_  __      ___ __  ___ / /_ | || |
| | | | __| |   / __| | | | `_ \| `_ ` _ \| | __| \ \ /\ / / `_ \/ __| `_ \| || |_
| |_| | |_| |   \__ \ |_| | |_) | | | | | | | |_   \ V  V /| |_) \__ \ (_) |__   _|
 \__,_|\__|_|___|___/\__,_|_.__/|_| |_| |_|_|\__|___\_/\_/ | .__/|___/\___/   |_|
           |_____|                             |_____|     |_|
*/

filename ft15f001 "c:/oto/utl_submit_wps64x,sas";
parmcards4;
%macro utl_submit_wps64x
(pgmx,resolve=N,returnVarName=,inputmacvar=N)/des="submiit a single quoted sas program to wps";

  * whatever you put in the Python or R clipboard will be returned in the macro variable
    returnVarName;

  * if you delay resolution, use resove=Y to resolve macros and macro variables passed to python;

  * write the program to a temporary file;

  %utlfkil(%sysfunc(pathname(work))/wps_pgmtmp.wps);
  %utlfkil(%sysfunc(pathname(work))/wps_pgm.wps);
  %utlfkil(%sysfunc(pathname(work))/wps_pgm001.wps);
  %utlfkil(wps_pgm.lst);

  filename wps_pgm "%sysfunc(pathname(work))/wps_pgmtmp.wps" lrecl=32756 recfm=v;
  data _null_;
    length pgm  $32756 cmd $32756;
    file wps_pgm ;
    %if %upcase(%substr(&resolve,1,1))=Y %then %do;
       pgm=resolve(&pgmx);
    %end;
    %else %do;
      pgm=&pgmx;
    %end;
    semi=countc(pgm,';');
      do idx=1 to semi;
        cmd=cats(scan(pgm,idx,';'),';');
        if index(cmd,"`") then cmd=tranwrd(cmd,"`","27"x);
        len=length(strip(cmd));
        put cmd $varying32756. len;
        putlog cmd $varying32756. len;
      end;
  run;

  filename wps_001 "%sysfunc(pathname(work))/wps_pgm001.wps" lrecl=255 recfm=v ;
  data _null_ ;
    length textin $ 32767 textout $ 255 ;
    file wps_001;
    infile "%sysfunc(pathname(work))/wps_pgmtmp.wps" lrecl=32767 truncover;
    format textin $char32767.;
    input textin $char32767.;
    putlog _infile_;
    if lengthn( textin ) <= 255 then put textin ;
    else do while( lengthn( textin ) > 255 ) ;
       textout = reverse( substr( textin, 1, 255 )) ;
       ndx = index( textout, ' ' ) ;
       if ndx then do ;
          textout = reverse( substr( textout, ndx + 1 )) ;
          put textout $char255. ;
          textin = substr( textin, 255 - ndx + 1 ) ;
    end ;
    else do;
      textout = substr(textin,1,255);
      put textout $char255. ;
      textin = substr(textin,255+1);
    end;
    if lengthn( textin ) le 255 then put textin $char255. ;
    end ;
  run ;

  %put ****** file %sysfunc(pathname(work))/wps_pgm.wps ****;

  filename wps_fin "%sysfunc(pathname(work))/wps_pgm.wps" lrecl=255 recfm=v ;
  data _null_;
      retain switch 0;
      infile wps_001;
      input;
      file wps_fin;
      if substr(_infile_,1,1) = "." then  _infile_= substr(left(_infile_),2);
      select;
         when(left(upcase(_infile_))=:"SUBMIT;")     switch=1;
         when(left(upcase(_infile_))=:"ENDSUBMIT;")  switch=0;
         otherwise;
      end;
      if lag(switch)=1 then  _infile_=compress(_infile_,";");
      if left(upcase(_infile_))= "ENDSUBMIT" then _infile_=cats(_infile_,";");
      put _infile_;
      putlog _infile_;
  run;quit;

  %let _loc=%sysfunc(pathname(wps_fin));
  %let _w=%sysfunc(compbl(C:\progra~1\worldp~1\wpsana~1\4\bin\wps.exe -autoexec c:\oto\Tut_Otowps.sas -config c:\cfg\wps.cfg -sasautos c:\otowps));
  %put &_loc;

  filename rut pipe "&_w -sysin &_loc";
  data _null_;
    file print;
    infile rut;
    input;
    put _infile_;
    putlog _infile_;
  run;

  filename rut clear;
  filename wps_pgm clear;
  data _null_;
    infile "wps_pgm.lst";
    input;
    putlog _infile_;
  run;quit;

  * use the clipboard to create macro variable;
  %if "&returnVarName" ne ""  %then %do;
    filename clp clipbrd ;
    data _null_;
     infile clp;
     input;
     putlog "*******  " _infile_;
     call symputx("&returnVarName.",_infile_,"G");
    run;quit;
  %end;

%mend utl_submit_wps64x;
;;;;;
run;quit;




/*              _
  ___ _ __   __| |
 / _ \ `_ \ / _` |
|  __/ | | | (_| |
 \___|_| |_|\__,_|

*/
