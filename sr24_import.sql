drop table if exists nutrient_data;
create table nutrient_data (
ndb_no MEDIUMINT UNSIGNED NOT NULL comment '5-digit Nutrient Databank number',
nutr_no SMALLINT UNSIGNED NOT NULL comment 'Unique 3-digit identifier code for a nutrient',
nutr_val decimal(18,5) NOT NULL comment 'Amount in 100 grams, edible portion',
num_data_pts decimal(18,5) not null comment 'Number of data points (previously called Sample_Ct) is the number of analyses used  to calculate the nutrient value. If the number of data points is 0, the value was calculated or imputed.',
str_error decimal(18,5) default null comment 'Standard error of the mean. Null if cannot be calculated. The standard error is also not  given if the number of data points is less than three.',
src_cd tinyint UNSIGNED default null comment 'Code indicating type of data.',
deriv_cd VARCHAR(4) default null comment 'Data Derivation Code  giving specific information on how the value is determined',
ref_ndb_no MEDIUMINT UNSIGNED default null comment 'NDB number of the item used to impute a missing value. Populated only for items added or updated starting with SR14.',
add_nutr_mark CHAR(1) default null comment 'Indicates a vitamin or mineral added for fortification or enrichment. This field is populated for ready-to-eat breakfast cereals and many brand-name hot cereals in food group 8.',
num_studies TINYINT UNSIGNED default null comment 'Number of studies.',
`min` smallint UNSIGNED default null comment 'Minimum value.',
`max` mediumint UNSIGNED default null comment 'Maximum value.',
df smallint unsigned default null comment 'Degrees of freedom.',
low_eb decimal(18,5) default null comment 'Lower 95% error bound.',
up_eb decimal(18,5) default null comment 'Upper 95% error bound.',
stat_cmt char(7) default null comment 'Statistical comments.',
addmod_date date default null comment 'Indicates when a value was either added to the database or last modified.',
cc char(0) default null comment 'Confidence Code indicating data quality, based on evaluation of sample plan, sample handling, analytical method, analytical quality control, and number of samples analyzed. Not included in this release, but is planned for future releases.');

load data infile 'NUT_DATA.txt' into table nutrient_data  fields terminated by '\^' enclosed by '~' LINES TERMINATED BY '\r\n' (ndb_no, nutr_no, nutr_val, num_data_pts, @str_error, @src_cd, @deriv_cd, @ref_ndb_no, @add_nutr_mark,@num_studies, @min, @max, @df, @low_eb, @up_eb, @stat_cmt, @addmod_date, @cc) set str_error = if(@str_error='',null,@str_error), src_cd = if(@src_cd='',null,@src_cd), deriv_cd = if(@deriv_cd='',null,@deriv_cd), ref_ndb_no= if(@ref_ndb_no='',null,@ref_ndb_no), add_nutr_mark = if(@add_nutr_mark='',null,@add_nutr_mark), num_studies = if(@num_studies='',null,@num_studies), `min` = if(@min='',null,@min), `max` = if(@max='',null,@max), df = if(@df = '',null,@df), low_eb = if(@low_eb='',null,@low_eb), up_eb = if(@up_eb='',null,@up_eb), stat_cmt =if(@stat_cmt='',null,@stat_cmt),addmod_date =if(@addmod_date='',null,concat_ws('-',right(@addmod_date,4),left(@addmod_date,2),'01')), cc =null ;

drop table if exists nutrient_definition;
create table nutrient_definition(
nutr_no SMALLINT(3) UNSIGNED NOT NULL comment 'Unique 3-digit identifier code for a nutrient.',
units  VARBINARY(6) NOT NULL comment 'Units of measure (mg, g, µg, and so on).', 
tagname VARCHAR(10) NOT NULL comment 'International Network of Food Data Systems (INFOODS) Tagnames.. A unique abbreviation for a nutrient/food component developed by INFOODS to aid  in the interchange of data.',
nutrdesc VARCHAR(34) NOT NULL comment 'Name of nutrient/food component.',
num_dec  CHAR(1) NOT NULL comment 'Number of decimal places to which a nutrient value is rounded.', 
sr_order SMALLINT(5) UNSIGNED NOT NULL comment 'Used to sort nutrient records in the same order as various reports produced from SR.'
);

load data infile 'NUTR_DEF.txt' into table nutrient_definition  fields terminated by '\^' enclosed by '~' LINES TERMINATED BY '\r\n';

drop table if exists source_code;
create table source_code (
src_cd CHAR(2) NOT NULL comment '2-digit code.',
srccd_desc VARCHAR(60) NOT NULL comment 'Description of source code th at identifies the type of nutrient data.'
); 

load data infile 'SRC_CD.txt' into table source_code  fields terminated by '\^' enclosed by '~' LINES TERMINATED BY '\r\n';

drop table if exists data_derivation_code;
create table data_derivation_code (
deriv_cd VARCHAR(4) NOT NULL comment 'Derivation Code.',
deriv_desc varchar(263) NOT NULL comment 'Description of derivation code giving specific information on how the value was determined.'
); 

load data infile 'DERIV_CD.txt' into table data_derivation_code  fields terminated by '\^' enclosed by '~' LINES TERMINATED BY '\r\n';

drop table if exists weight;
create table weight (
ndb_no MEDIUMINT(5) UNSIGNED NOT NULL comment '5-digit Nutrient Databank number.',
seq tinyint unsigned NOT NULL comment 'Sequence number.',
amount decimal(9,4) NOT NULL comment 'Unit modifier (for example, 1 in .1 cup.).',
msre_desc VARCHAR(77) NOT NULL comment 'Description (for example, cup, diced, and 1-inch pieces).',
gm_wgt SMALLINT UNSIGNED NOT NULL comment 'Gram weight.',
num_data_pts smallint unsigned comment 'Number of data points.',
std_dev decimal(9,4) comment 'Standard deviation.'
); 

load data infile 'WEIGHT.txt' into table weight fields terminated by '\^' enclosed by '~' LINES TERMINATED BY '\r\n'
(ndb_no, seq, amount, msre_desc, gm_wgt, @num_data_pts, @std_dev) set num_data_pts = if(@num_data_pts = '', null, @num_data_pts), std_dev = if(@std_dev='', null, @std_dev);


drop table if exists footnote;
create table footnote (
ndb_no MEDIUMINT(5) UNSIGNED NOT NULL comment '5-digit Nutrient Databank number.',
footnt_no TINYINT(2) UNSIGNED ZEROFILL NOT NULL comment 'Sequence number. If a given footnote applies to more than one nutrient number, the same footnote number is used. As a result,this file cannot be indexed. ',
footnt_typ CHAR(1) NOT NULL comment 'Type of footnote: D = footnote adding information to the food  description;  M = footnote adding information to measure description;  N = footnote providing additional information on a nutrient value. If the Footnt_typ = N, th e Nutr_No will also be filled in.',
nutr_no SMALLINT(3) UNSIGNED default null comment 'Unique 3-digit identifier code for a nutrient to which footnote applies.',
footnt_txt VARCHAR(199) NOT NULL comment 'Footnote text.'
); 
load data infile 'FOOTNOTE.txt' into table footnote fields terminated by '\^' enclosed by '~' LINES TERMINATED BY '\r\n'
(ndb_no, footnt_no, footnt_typ, @nutr_no, footnt_txt) set nutr_no = if(@nutr_no='',null,@nutr_no);

drop table if exists data_sources_link;
create table data_sources_link (
ndb_no MEDIUMINT(5) UNSIGNED NOT NULL comment '5-digit Nutrient Databank number.',
nutr_no SMALLINT(3) UNSIGNED NOT NULL comment 'Unique 3-digit identifier code for a nutrient.',
datasrc_id CHAR(5) NOT NULL comment 'Unique ID identifying the reference/source.'
); 

load data infile 'DATSRCLN.txt' into table data_sources_link fields terminated by '\^' enclosed by '~' LINES TERMINATED BY '\r\n';

drop table if exists data_sources;
create table data_sources (
datasrc_id CHAR(5) NOT NULL comment 'Unique number identifying the refe rence/source.',
authors VARCHAR(110) NOT NULL comment 'List of authors for a j ournal article or name of sponsoring organization for other documents.',
title VARCHAR(185) NOT NULL comment 'Title of article or name  of document, such as a report from a company or trade association.',
`year` year comment 'Year article or document was published.',
journal VARCHAR(87) NOT NULL comment 'Name of the journal  in which the article was published.',
vol_city VARCHAR(16) comment 'Volume number for journal articles, books, or reports; city where sponsoring organi zation is located. ',
issue_state CHAR(3) comment 'Issue number for journal article; State where the sponsoring organization is located.',
start_page smallint comment 'Starting page number of article/document.',
end_page smallint comment 'Ending page number of article/document.'
); 

load data infile 'DATA_SRC.txt' into table data_sources fields terminated by '\^' enclosed by '~' LINES TERMINATED BY '\r\n'
(datasrc_id, authors, title, @year, journal, @vol_city, @issue_state, @start_page, @end_page) set `year` = if(@year='',null,@year), vol_city=if(@vol_city='',null,@vol_city), issue_state=if(@issue_state='',null,@issue_state), start_page=if(@start_page='',null,@start_page), end_page=if(@end_page='',null,@end_page) ;


drop table if exists food_desc;
create table food_desc (
ndb_no MEDIUMINT(5) UNSIGNED NOT NULL comment '5-digit Nutrient Databank  number that uniquely identifies a food item.  If this field is defined as numeric, the leading zero will be lost. ',
fdgrp_cd SMALLINT(4) UNSIGNED NOT NULL comment '4-digit code indicating food group to which a food item belongs.',
long_desc varchar(200) comment '200-character description of food item.',
shrt_desc VARCHAR(60) NOT NULL comment '60-character abbrev iated description of food item. Generated from the 200-character description using abbreviations in Appendix A. If  short description is longer than 60 characters, additional abbreviations are made.',
comname VARCHAR(80) NOT NULL comment 'Other names commonly used to describe a food, including local or regional names for various foods, for example, .soda. or .pop. for .carbonated beverages.. ',
manufacname VARCHAR(64) NOT NULL comment 'Indicates the company that manufactured the product, when appropriate.',
survey CHAR(1) NOT NULL comment 'Indicates if the food  item is used in the USDA Food and Nutrient Database for Dietary Studies (FNDDS) and thus has a complete nutrient profile for the 65 FNDDS nutrients.',
ref_desc VARCHAR(134) NOT NULL comment 'Description of inedible parts of a food item (refuse), such as seeds or bone.',
refuse tinyint unsigned comment 'Percentage of refuse.',
sciname VARCHAR(63) NOT NULL comment 'Scientific name of the food item. Given for the least processed form of the food (usually raw), if applicable.',
n_factor decimal(18,4) comment 'Factor for converting nitrogen to protein',
pro_factor decimal(18,4) comment 'Factor for calculating calories from protein',
fat_factor decimal(18,4) comment 'Factor for calculating calories from fat',
cho_factor decimal(18,4) comment 'Factor for calculating calories from carbohydrate'
); 

load data infile 'FOOD_DES.txt' into table food_desc fields terminated by '\^' enclosed by '~' LINES TERMINATED BY '\r\n'
(ndb_no, fdgrp_cd, long_desc, shrt_desc, comname, manufacname, survey, ref_desc, @refuse, sciname, @n_factor, @pro_factor, @fat_factor, @cho_factor) 
set refuse = if(@refuse='',null,@refuse), n_factor = if(@n_factor='',null,@n_factor), pro_factor = if(@pro_factor='',null,@pro_factor), fat_factor = if(@fat_factor='',null,@fat_factor), cho_factor = if(@cho_factor='',null,@cho_factor);


drop table if exists food_grp_desc;
create table food_grp_desc (
fdgrp_cd SMALLINT(4) UNSIGNED NOT NULL comment '4-digit code identi fying a food group. Only the first 2 digits are currently assigned. In  the future, the last 2 digits may be used. Codes may not be consecutive.',
fdgrp_desc VARCHAR(33) NOT NULL comment 'Name of food group.'
); 

load data infile 'FD_GROUP.txt' into table food_grp_desc fields terminated by '\^' enclosed by '~' LINES TERMINATED BY '\r\n';

drop table if exists langual_factor;
create table langual_factor (
ndb_no SMALLINT(5) UNSIGNED NOT NULL comment '5-digit Nutrient Databank number that uniquely identifies a food item.  If this field is  defined as numeric, the leading zero will be lost.',
factor_code CHAR(5) NOT NULL comment 'The LanguaL factor from the Thesaurus'
); 

load data infile 'LANGUAL.txt' into table langual_factor fields terminated by '\^' enclosed by '~' LINES TERMINATED BY '\r\n';

drop table if exists langual_fact_desc;
create table langual_fact_desc (
factor_code CHAR(5) NOT NULL comment 'The LanguaL factor from the Thesaurus. Only those codes used to factor the foods contained in the LanguaL Factor file are included in this file',
description  VARCHAR(66) NOT NULL comment 'The description of the LanguaL Factor Code from the thesaurus'
); 

load data infile 'LANGDESC.txt' into table langual_fact_desc fields terminated by '\^' enclosed by '~' LINES TERMINATED BY '\r\n';



