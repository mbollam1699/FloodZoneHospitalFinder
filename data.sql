--
-- PostgreSQL database dump
--

-- Dumped from database version 16.2
-- Dumped by pg_dump version 16.2

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- Data for Name: flood_zones; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.flood_zones (id, area) FROM stdin;
98	0103000020E6100000010000000500000097E5EB32FC1855C0A01518B2BAE14040A530EF71A61855C0533E0455A3E14040B83A00E2AE1855C0FD4E93196FE140405D6C5A29041955C0AD4F39268BE1404097E5EB32FC1855C0A01518B2BAE14040
100	0103000020E610000001000000040000007CD45FAFB01855C06ADFDC5F3DE04040F3E49A02991855C0F20698F90EE040404434BA83D81855C0759483D904E040407CD45FAFB01855C06ADFDC5F3DE04040
121	0103000020E61000000100000005000000A0FD4811191855C04AB3791C06E740408177F2E9B11755C0942EFD4B52E74040533E0455A31755C08E041A6CEAE64040F3E32F2DEA1755C0AC6F6072A3E64040A0FD4811191855C04AB3791C06E74040
\.


--
-- Data for Name: hospitals; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.hospitals (id, name, location, address, phone_no, state) FROM stdin;
9	23D MEDICAL GROUP	0101000020E61000005446AF4844CD54C01E7186EAFFF93E40	3278 MITCHELL BOULEVARD	(229) 257-2778	\N
10	30TH ADJUTANT GENERAL RECEPTION BATTALION - TMC 4	0101000020E61000008356BB811D8A54C01AAB07AB35B64040	7950 MARTIN LOOP	(706) 544-9493	\N
11	78TH MEDICAL GROUP	0101000020E6100000C5FD0DFB79E554C0CB3F65C2504D4040	655 7TH STREET, BUILDING 700, TRICARE OPERATIONS	(478) 327-7850	\N
12	DWIGHT D. EISENHOWER ARMY MEDICAL CENTER	0101000020E6100000FE36F6B20E8854C07E92962515B74040	300 EAST HOSPITAL ROAD	(706) 787-5811	\N
13	MARTIN ARMY COMMUNITY HOSPITAL	0101000020E6100000D48B6F62673B55C041E0F557972F4040	6600 VAN AALST BOULEVARD	(762) 408-2604	\N
14	WINN ARMY COMMUNITY HOSPITAL	0101000020E61000004E48C6C56C6654C08CE86C3B4CDF3F40	1061 HARMON AVE	(912) 435-6965	\N
15	ADVENTHEALTH GORDON	0101000020E61000009DD5027B4C3B55C09C3F5C284F414140	1035 RED BUD ROAD	(706) 629-2895	\N
16	ADVENTHEALTH MURRAY	0101000020E6100000ED31EC8B1F3255C002452C62D8634140	707 OLD DALTON ELLIJAY ROAD, PO BOX 1406	(706) 517-2031	\N
17	APPLING HOSPITAL	0101000020E61000007028198C539654C0D8CF498CF1C43F40	163 E TOLLISON STREET	(912) 367-9841	\N
18	ATRIUM HEALTH NAVICENT REHABILITATION HOSPITAL	0101000020E6100000F313B5D18CEB54C07A2AD0BC56724040	3351 NORTHSIDE DRIVE	(478) 471-6500	\N
19	ATRIUM HEALTH NAVICENT THE MEDICAL CENTER	0101000020E61000006075811EACE854C0BCEE2910A86A4040	777 HEMLOCK STREET	(478) 633-1000	\N
20	AU MEDICAL CENTER	0101000020E61000001B04A956577F54C0BFE7F2AC45BC4040	1120 15TH STREET	(706) 721-6569	\N
21	BACON COUNTY HOSPITAL	0101000020E61000007E6D601F5B9D54C0631504C91A8A3F40	302 SOUTH WAYNE STREET	(912) 632-8961	\N
22	BLECKLEY MEMORIAL HOSPITAL	0101000020E6100000EFC6C4DE32D654C060E69E2245314040	145 PEACOCK STREET	(478) 934-6211	\N
23	BROOKS COUNTY HOSPITAL	0101000020E6100000AFD5BBCBC7E354C056D4601A86CB3E40	903 N COURT STREET	(912) 263-4171	\N
24	BURKE MEDICAL CENTER	0101000020E61000009525212ECC8054C09AA74255AF8A4040	351 SOUTH LIBERTY STREET	(706) 554-4435	\N
25	CANDLER COUNTY HOSPITAL	0101000020E6100000F6C2748C318454C06EBE32EB1C344040	400 CEDAR STREET	(912) 685-5741	\N
26	CANDLER HOSPITAL	0101000020E6100000BCB1A030684654C05D3E27F79A034040	5353 REYNOLDS STREET	(912) 819-6000	\N
27	CHATUGE REGIONAL HOSPITAL	0101000020E61000000F5DF52540F054C0866EDD6A29794140	110 S MAIN STREET	(706) 896-2222	\N
28	CHI MEMORIAL HOSPITAL - GEORGIA	0101000020E61000000DEB5B20E05055C0BC53C74B33794140	100 GROSS CRESCENT CIRCLE	(770) 874-5400	\N
29	CHILDREN'S HEALTHCARE OF ATLANTA AT EGLESTON	0101000020E6100000716AB125751455C00ED55AB993E54040	1405 CLIFTON ROAD NE	(404) 785-6101	\N
30	CHILDREN'S HEALTHCARE OF ATLANTA AT SCOTTISH RITE	0101000020E61000002D4A9E25A71655C02CA7B17BFAF34040	1001 JOHNSON FERRY ROAD	(404) 785-5252	\N
31	CLINCH MEMORIAL HOSPITAL	0101000020E61000009A021DD6E9B054C0186468C8BA083F40	1050 VALDOSTA HIGHWAY	(912) 487-5211	\N
32	COASTAL BEHAVIORAL HEALTH	0101000020E610000081016B72844654C0B4E984A742014040	633 STEPHENSON AVENUE	(912) 354-3911	\N
33	COASTAL HARBOR TREATMENT CENTER	0101000020E6100000719052011E4654C0F196717491014040	1150 CORNELL AVE	(912) 354-3911	\N
34	COFFEE REGIONAL MEDICAL CENTER, INC	0101000020E610000034EC415255B754C06B4D2D3ADD823F40	1101 OCILLA ROAD	(912) 383-5620	\N
35	COLQUITT REGIONAL MEDICAL CENTER	0101000020E61000005ECF21BAF1F154C0A9E4524B29203F40	3131 THOMASVILLE HWY, PO BOX 40	(229) 985-3420	\N
36	COLUMBUS SPECIALTY HOSPITAL, INC	0101000020E6100000C8A83AFD033F55C010C43F8D773D4040	616 19TH STREEET	(706) 494-4075	\N
37	CRISP REGIONAL HOSPITAL	0101000020E61000007FAF958E01F254C0BCD7FFEF3EFA3F40	902 7TH STREET NORTH	(229) 276-3100	\N
38	DOCTORS HOSPITAL	0101000020E6100000981B672E0B8654C01EE3697D3ABE4040	3651 WHEELER ROAD	(706) 651-6008	\N
39	DODGE COUNTY HOSPITAL	0101000020E6100000C8BA345562CB54C0869CCE80C0174040	901 GRIFFIN AVE	(478) 448-4067	\N
40	DONALSONVILLE HOSPITAL INC	0101000020E61000001E6A1D4D5C3855C08B5E78EB1D0D3F40	102 HOSPITAL CIR	(229) 524-5217	\N
41	DORMINY MEDICAL CENTER	0101000020E61000004C12533BA6D054C0FC3FA09693B23F40	200 PERRY HOUSE ROAD, BOX 1447	(229) 424-7100	\N
42	EAST CENTRAL REGIONAL HOSPITAL	0101000020E61000006D1FD188C28054C0AE7060ACCEB24040	3405 MIKE PADGETT HWY	(706) 792-7006	\N
43	EAST GEORGIA REGIONAL MEDICAL CENTER	0101000020E61000004A498B0A477154C02F5B5FE217354040	1499 FAIR ROAD	(912) 486-1500	\N
44	EFFINGHAM HEALTH SYSTEM	0101000020E6100000010483D6895454C06E249E26922E4040	459 GA HIGHWAY 119 SOUTH	(912) 754-0160	\N
45	ELBERT MEMORIAL HOSPITAL	0101000020E61000003CBF2841FFB754C099B170AB830E4140	4 MEDICAL DRIVE	(706) 213-2535	\N
46	EMANUEL MEDICAL CENTER	0101000020E61000003ACAC16C429654C09E1373F7D64B4040	117 KITE ROAD	(478) 289-1304	\N
47	EMORY DECATUR HOSPITAL	0101000020E610000051CDF6321B1255C0A842B06842E54040	2701 N DECATUR ROAD	(404) 501-1000	\N
48	EMORY HILLANDALE HOSPITAL	0101000020E61000007BB1838C780955C0F56FD1A844DA4040	2801 DEKALB MEDICAL PARKWAY	(404) 501-8040	\N
49	EMORY JOHNS CREEK HOSPITAL	0101000020E6100000F0C9DCDF4D0B55C0CCE09CCF88084140	6325 HOSPITAL PARKWAY	(678) 474-7000	\N
50	EMORY LONG TERM ACUTE CARE	0101000020E610000033E9C626BF1255C081CF0F2384E34040	450 NORTH CANDLER STREET	(404) 377-0221	\N
51	EMORY REHABILITATION HOSPITAL	0101000020E61000001FC0BF94831455C0E63B5BB4BEE54040	1441 CLIFTON ROAD NE	(404) 712-5512	\N
52	EMORY UNIV HOSPITAL - EMORY UNIV ORTHO AND SPINE	0101000020E6100000E62BBB3FE20F55C04A134ABAC1E94040	1455 MONTREAL ROAD	(404) 712-2000	\N
53	EMORY UNIVERSITY HOSPITAL	0101000020E6100000132DD4F59F1455C087440C0161E54040	1364 CLIFTON ROAD NE	(404) 686-8500	\N
54	EMORY UNIVERSITY HOSPITAL MIDTOWN	0101000020E6100000C45EC535C01855C053CEB45074E24040	550 PEACHTREE STREET NE	(404) 686-4411	\N
55	EMORY UNIVERSITY HOSPITAL SMYRNA	0101000020E61000004AC91759D72055C04A4AD5D1CCED4040	3949 SOUTH COBB DRIVE	(404) 686-7288	\N
56	ENCOMPASS HEALTH REHAB HOSPITAL OF SAVANNAH	0101000020E6100000151DC9E5FF4554C076E0DE2DF7004040	6510 SEAWRIGHT DRIVE	(912) 235-6000	\N
57	ENCOMPASS HEALTH REHABILITATION HOSPITAL CUMMING	0101000020E6100000359BC761300855C00114234BE6164140	1165 SANDERS ROAD	(470) 533-4200	\N
58	EVANS MEMORIAL HOSPITAL	0101000020E61000007BC3D89D897954C0FFA0A2A83B154040	200 N RIVER STREET	(912) 739-5105	\N
59	FAIRVIEW PARK HOSPITAL	0101000020E6100000E4109281D3BC54C03EB555A41D444040	200 INDUSTRIAL BOULEVARD	(478) 274-3100	\N
60	FANNIN REGIONAL HOSPITAL	0101000020E6100000CDEA7827FA1755C022D4B96078754140	2855 OLD HIGHWAY 5 NORTH	(706) 632-3711	\N
61	FLINT RIVER COMMUNITY HOSPITAL	0101000020E6100000F5106CE0F70155C09DAE9B10C2254040	509 SUMTER STREET, PO BOX 770	(478) 472-3100	\N
62	FLOYD MEDICAL CENTER	0101000020E61000006AA8EE1D774B55C01556099A3F214140	304 TURNER MCCALL BLVD, PO BOX 233	(706) 509-6900	\N
63	GEORGIA REGIONAL HOSP SAVANNAH	0101000020E6100000C21AE39A2D4554C01B15728410004040	1915 EISENHOWER DRIVE	(912) 356-2045	\N
64	GEORGIA REGIONAL HOSPITAL ATLANTA	0101000020E610000018217EF68A1155C027CAB5D31CD94040	3073 PANTHERSVILLE ROAD	(404) 243-2100	\N
65	GRADY GENERAL HOSPITAL	0101000020E6100000C6BB2BD4BD0C55C009466F021DDD3E40	1155 5TH STREET SE	(229) 377-0251	\N
66	GRADY MEMORIAL HOSPITAL	0101000020E610000077C2E8456F1855C0B59B2A2941E04040	80 JESSE HILL JR DRIVE SE	(404) 616-4252	\N
67	GREENLEAF CENTER	0101000020E6100000424D80A395D054C07576534633DC3E40	2209 PINEVIEW DRIVE	(229) 671-6601	\N
68	HABERSHAM COUNTY MEDICAL CTR	0101000020E6100000F2930FE65BE254C0220FAFB16C4A4140	541 HISTORIC HIGHWAY 441 NORTH	(706) 754-2161	\N
69	HAMILTON MEDICAL CENTER	0101000020E6100000BFADA2DC093F55C0EF6DC00816654140	1200 MEMORIAL DRIVE	(706) 272-6105	\N
70	HIGGINS GENERAL HOSPITAL	0101000020E61000009DB32E03484955C0E6F9DBB7BDDB4040	200 ALLEN MEMORIAL DRIVE	(770) 812-2000	\N
71	HOUSTON MEDICAL CENTER	0101000020E61000005A3D503C61E854C052D436510D4F4040	1601 WATSON BOULEVARD	(478) 922-4281	\N
72	HUGHES SPALDING CHILDREN'S HOSPITAL	0101000020E6100000CF5D1AD80D1555C085583F2E58EA4040	1711 TULLIE CIRCLE NE	(404) 785-6096	\N
73	IRWIN COUNTY HOSPITAL	0101000020E61000002465E65D10D054C01C312726779A3F40	710 N IRWIN AVENUE	(229) 468-3845	\N
74	JASPER MEMORIAL HOSPITAL	0101000020E610000014ACB352EFEB54C078DF637637A84040	898 COLLEGE STREET	(706) 468-6411	\N
75	JEFF DAVIS HOSPITAL	0101000020E61000003644EC7EDBA654C03D82FA1A72DB3F40	163 SOUTH TALLAHASSEE STREET	(912) 375-7781	\N
76	JEFFERSON HOSPITAL	0101000020E610000027455476F49954C0FB6B815643814040	1067 PEACHTREE ST	(478) 625-7000	\N
77	JENKINS COUNTY MEDICAL CENTER	0101000020E6100000BD9CA774CF7B54C0F0CCFC51F1664040	931 EAST WINTHROPE AVENUE	(478) 982-4221	\N
78	JOHN D ARCHBOLD MEMORIAL HOSPITAL	0101000020E6100000F226016239FE54C0DC27CB3946D33E40	915 GORDON AVENUE AND MIMOSA DRIVE	(229) 228-2880	\N
79	LAKEVIEW BEHAVIORAL HEALTH SYSTEM	0101000020E6100000E1589BEFF50D55C0FCC84A1F7CFA4040	1 TECHNOLOGY PARKWAY SOUTH	(678) 713-2600	\N
80	LANDMARK HOSPITAL OF ATHENS, LLC	0101000020E61000003075042E57DA54C01BDB0817B4FB4040	775 SUNSET DRIVE	(706) 425-1518	\N
81	LANDMARK HOSPITAL OF SAVANNAH	0101000020E61000001B408544164654C0F7D8C83BA8034040	800 E 68TH STREET	(573) 331-8420	\N
82	LAUREL HEIGHTS HOSPITAL	0101000020E61000005E503AEC191655C04F6229F5D9E34040	934 BRIARCLIFF ROAD	(404) 888-7860	\N
83	LIBERTY REGIONAL MEDICAL CENTER	0101000020E610000094409479756654C03EEF8466F0D63F40	462 E G MILES PARKWAY	(912) 369-9438	\N
84	LIFEBRITE COMMUNITY HOSPITAL OF EARLY	0101000020E6100000158AF8778B3C55C06E33F4D3A85F3F40	11740 COLUMBIA STREET	(229) 723-4241	\N
85	LIGHTHOUSE CARE CENTER OF AUGUSTA	0101000020E6100000B8DB606E988554C0F3693E7CD3BE4040	3100 PERIMETER PARKWAY	(706) 651-0005	\N
86	LOWER OCONEE COMMUNITY HOSPITAL, INC	0101000020E610000031CF8C7603AB54C0652772770C174040	111 NORTH 3RD STREET	(912) 523-5113	\N
87	MEDICAL CENTER OF PEACH COUNTY - NAVICENT HEALTH	0101000020E6100000D074C0BF92F054C0258D3465654D4040	1960 HIGHWAY 247 CONNECTOR	(478) 654-2000	\N
88	MEMORIAL HEALTH MEADOWS HOSPITAL	0101000020E610000099FAD40C049854C00A60F33FB31A4040	1 MEADOWS PARKWAY	(912) 535-5828	\N
89	MEMORIAL HEALTH UNIVERSITY MEDICAL CENTER	0101000020E610000094EF00ECAF4554C01E8F956FE8034040	4700 WATERS AVENUE	(912) 350-3691	\N
90	MEMORIAL HOSPITAL AND MANOR	0101000020E61000004B74754B5B2355C09EC70F321CE73E40	1500 E SHOTWELL STREET	(229) 246-3500	\N
91	MEMORIAL SATILLA HEALTH	0101000020E6100000A4656A334A9654C0E068E81BA8393F40	1900 TEBEAU STREET	(912) 287-2500	\N
92	MILLER COUNTY HOSPITAL	0101000020E61000001897478A0A2F55C0FE799E68EC2C3F40	209 N CUTHBERT STREET	(229) 758-4231	\N
93	MITCHELL COUNTY HOSPITAL	0101000020E61000006320D79F270D55C04FD70BECCE3A3F40	90 STEPHENS STREET	(229) 336-5284	\N
94	MONROE COUNTY HOSPITAL	0101000020E6100000FB4F8A988AFC54C09B4AB33700844040	88 MARTIN LUTHER KING JR DRIVE	(478) 994-2521	\N
95	MORGAN MEDICAL CENTER	0101000020E610000026CFED0C30DE54C0805B3D48CBC84040	1740 LIONS CLUB ROAD	(706) 342-1667	\N
96	MOUNTAIN LAKES MEDICAL CENTER	0101000020E6100000624216B32FD954C0D8ADAFBF36724140	162 LEGACY POINT	(706) 782-3100	\N
97	NAVICENT HEALTH BALDWIN	0101000020E61000004D33BCDDBBCF54C078616BB6728B4040	821 NORTH COBB STREET	(478) 454-3550	\N
98	NORTHEAST GEORGIA MEDICAL CENTER BARROW	0101000020E6100000C6FD47A643ED54C03DD175E107014140	316 NORTH BROAD STREET	(770) 848-8611	\N
99	NORTHEAST GEORGIA MEDICAL CENTER LUMPKIN	0101000020E6100000BAC8B1B370FE54C0EC387637EC424140	227 MOUNTAIN DRIVE	(770) 219-7146	\N
100	NORTHEAST GEORGIA MEDICAL CENTER, INC	0101000020E6100000795E85EF58F454C03CF8AA11D1264140	743 SPRING STREET	(770) 535-3553	\N
101	NORTHSIDE HOSPITAL	0101000020E61000001C8388B3A61655C0EBE65E3757F44040	1000 JOHNSON FERRY ROAD NE	(404) 851-8000	\N
102	NORTHSIDE HOSPITAL CHEROKEE	0101000020E6100000CD1DFD2FD71D55C00F80B8AB571D4140	450 NORTHSIDE CHEROKEE BOULEVARD	(770) 244-1000	\N
103	NORTHSIDE HOSPITAL DULUTH	0101000020E61000003846578E750A55C0176578E4F6FF4040	3620 HOWELL FERRY ROAD	(678) 312-1000	\N
104	NORTHSIDE HOSPITAL FORSYTH	0101000020E61000009A93BCDF0D0955C06A481E80BB164140	1200 NORTHSIDE FORSYTH DRIVE	(770) 844-3200	\N
105	NORTHSIDE HOSPITAL GWINNETT	0101000020E6100000B7D672C21F0155C0DE01BFC259FB4040	1000 MEDICAL CENTER BOULEVARD	(678) 312-1000	\N
106	OPTIM MEDICAL CENTER - SCREVEN	0101000020E6100000A184BAC4686954C0CCE7813408604040	215 MIMS ROAD	(912) 564-7426	\N
107	OPTIM MEDICAL CENTER - TATTNALL	0101000020E6100000A0C67BDDFB8654C0D255BABB4E0A4040	247 S MAIN STREET	(912) 557-1000	\N
108	PEACHFORD BEHAVIORAL HEALTH SYSTEM OF ATLANTA	0101000020E6100000E7996E443D1355C05D974CDBE0F64040	2151 PEACHFORD ROAD	(770) 455-3200	\N
109	PERRY HOSPITAL	0101000020E61000006DEEE00E71ED54C00A2430EFD43A4040	1120 MORNINGSIDE DR	(478) 987-3600	\N
110	PHOEBE PUTNEY MEMORIAL HOSPITAL	0101000020E6100000CB010EE3260A55C00BB43BA418973F40	417 THIRD AVENUE	(229) 312-4068	\N
111	PHOEBE SUMTER MEDICAL CENTER	0101000020E610000098C86020631055C08C2ED23892084040	126 HIGHWAY 280 W	(229) 931-1280	\N
112	PHOEBE WORTH MEDICAL CENTER	0101000020E61000001566CA1CC5F554C0C49F974000833F40	807 SOUTH ISABELLA STREET	(229) 777-3851	\N
113	PIEDMONT ATHENS REGIONAL MEDICAL CENTER	0101000020E6100000495099EE77D954C04145B4A10BFB4040	1199 PRINCE AVENUE	(706) 475-7000	\N
114	PIEDMONT CARTERSVILLE MEDICAL CENTER	0101000020E6100000FCB3B48DDE3255C0854CA6C8A9194140	960 JOE FRANK HARRIS PARKWAY	(470) 490-1000	\N
115	PIEDMONT COLUMBUS REGIONAL MIDTOWN	0101000020E6100000271FB39ACB3E55C0BE324EC78C3D4040	710 CENTER STREET	(706) 571-1000	\N
116	PIEDMONT COLUMBUS REGIONAL NORTHSIDE	0101000020E61000006CECAFAAE03C55C05273034F6B444040	100 FRIST COURT	(706) 494-2101	\N
117	PIEDMONT EASTSIDE MEDICAL CENTER	0101000020E6100000CF9C3746590155C0C31F8F2A54F04040	1700 MEDICAL WAY	(770) 979-0200	\N
118	PIEDMONT FAYETTE HOSPITAL	0101000020E6100000B46F72E8822055C02837DDF4DFB94040	1255 HIGHWAY 54 WEST	(770) 719-7000	\N
119	PIEDMONT HENRY HOSPITAL	0101000020E6100000DC2815018C0E55C088EBDEAB52C14040	1133 EAGLE'S LANDING PARKWAY	(678) 604-1000	\N
120	PIEDMONT HOSPITAL	0101000020E6100000CE95D6193E1955C07953154387E74040	1968 PEACHTREE RD NW	(404) 605-5000	\N
121	PIEDMONT MACON MEDICAL CENTER	0101000020E610000002DED98998E754C040BB09DF776C4040	350 HOSPITAL DRIVE	(478) 765-7000	\N
122	PIEDMONT MACON NORTH HOSPITAL	0101000020E6100000D8B4942476EC54C00AD44953906F4040	400 CHARTER BOULEVARD	(478) 757-8200	\N
123	PIEDMONT MOUNTAINSIDE HOSPITAL INC	0101000020E610000066A92F2A6D1A55C080048BE4A73A4140	1266 HIGHWAY 515 SOUTH	(706) 301-5269	\N
124	PIEDMONT NEWNAN HOSPITAL, INC	0101000020E6100000112A613B523055C0E45B6963B6AD4040	745 POPLAR ROAD	(770) 400-2300	\N
125	PIEDMONT NEWTON HOSPITAL	0101000020E61000007FBC57AD4CF654C069E388B5F8CC4040	5126 HOSPITAL DRIVE NE	(770) 786-7053	\N
126	PIEDMONT ROCKDALE HOSPITAL	0101000020E6100000EACE13CF190055C09BBA5DF521D74040	1412 MILSTEAD AVENUE NE	(770) 918-3000	\N
127	PIEDMONT WALTON HOSPITAL, INC	0101000020E61000005B08725002F054C078B492D243E64040	2151 W SPRING STREET	(770) 267-8461	\N
128	POLK MEDICAL CENTER	0101000020E6100000FE4EACB68F4C55C03C644EC0C4014140	2360 ROCKMART HIGHWAY	(770) 748-2500	\N
129	PUTNAM GENERAL HOSPITAL	0101000020E6100000A59FB292BDD754C0786AE4A9FDAA4040	101 LAKE OCONEE PARKWAY	(706) 485-2711	\N
130	REDMOND REGIONAL MEDICAL CENTER	0101000020E61000004865B3B8794C55C045E63EF76D234140	501 REDMOND ROAD	(706) 802-3012	\N
131	REGENCY HOSPITAL COMPANY OF MACON, LLC	0101000020E610000066E7C0B460E754C05339F59A816C4040	535 COLISEUM DRIVE	(478) 803-7300	\N
132	REGIONAL PSYCHIATRIC DIVISION - CENTRAL STATE	0101000020E6100000E2033BFE0BCD54C002284696CC834040	620 BROAD STREET	(478) 445-4128	\N
133	REHABILITATION HOSPITAL OF HENRY	0101000020E6100000FE28EACCBD0D55C064AF567153BE4040	2200 PATRICK HENRY PARKWAY	(470) 713-2000	\N
134	REHABILITATION HOSPITAL OF NEWNAN	0101000020E6100000C94CF5A61A3055C048C6C5AC72AE4040	2101 EAST NEWNAN CROSSING BLVD	(678) 552-6200	\N
135	RIDGEVIEW INSTITUTE	0101000020E61000000654511FB52055C0DEB608EF9FED4040	3995 S COBB DRIVE SE	(770) 434-4567	\N
136	RIDGEVIEW INSTITUTE MONROE	0101000020E6100000D51BBD33FDED54C0F852BAEC3EE44040	709 BREEDLOVE DRIVE	(678) 635-8730	\N
137	RIVERWOODS BEHAVIORAL HEALTH SYSTEM	0101000020E6100000D9DCA880011955C0F1404BF485CA4040	223 MEDICAL CENTER DRIVE	(770) 991-8500	\N
138	ROOSEVELT WARM SPRINGS LTAC HOSPITAL	0101000020E61000005AC3FB604F2C55C092E3565AA9714040	6135 ROOSEVELT HIGHWAY, PO BOX 280	(706) 655-5515	\N
139	ROOSEVELT WARM SPRINGS REHABILITATION HOSPITAL	0101000020E610000067859EA46B2C55C0C0F640E993714040	6135 ROOSEVELT HIGHWAY, PO BOX 280	(706) 655-5515	\N
140	SAINT JOSEPH'S HOSPITAL OF ATLANTA, INC	0101000020E6100000FED5E3BE551655C01D0A762E52F44040	5665 PEACHTREE DUNWOODY ROAD	(678) 843-5720	\N
141	SELECT SPECIALTY HOSPITAL - AUGUSTA, INC	0101000020E61000005A54594E617F54C0F8ACE77BF8BC4040	1537 WALTON WAY	(706) 731-1200	\N
142	SELECT SPECIALTY HOSPITAL - MIDTOWN ATLANTA, LLC	0101000020E6100000B6E9190C7F1855C04EC55B210BE34040	705 JUNIPER STREET NE	(404) 873-2871	\N
143	SELECT SPECIALTY HOSPITAL - SAVANNAH, INC	0101000020E6100000DB153C7D6B4654C0D951073F92034040	5353 REYNOLDS STREET 4 SOUTH	(912) 819-7986	\N
144	SGMC BERRIEN CAMPUS	0101000020E6100000B23AE6FA46CF54C09190B376FC333F40	1221 E MCPHERSON AVENUE	(229) 543-7100	\N
145	SGMC LANIER CAMPUS	0101000020E6100000E7E954E081C554C0ADA368EDCF0A3F40	116 WEST THIGPEN AVENUE	(229) 482-8402	\N
146	SHEPHERD CENTER	0101000020E61000002DC7F164331955C00B555A14B0E74040	2020 PEACHTREE RD NW	(404) 350-7311	\N
147	SO CRESCENT BEH HLTH SYS - ANCHOR HOSPITAL CAMPUS	0101000020E6100000ACC397AAF01C55C07597DDF6B1CD4040	5454 YORKTOWNE DRIVE	(770) 991-6044	\N
148	SO CRESCENT BEH HLTH SYS - CRESCENT PINES CAMPUS	0101000020E610000058B329B2310E55C08CDA1E39A9C14040	1000 EAGLES LANDING PARKWAY	(770) 474-8888	\N
149	SOUTH GEORGIA MEDICAL CENTER	0101000020E61000004BDEC68755D254C0871B6CC1BDDC3E40	2501 NORTH PATTERSON STREET, PO BOX 1727	(229) 333-1020	\N
150	SOUTHEAST GEORGIA HEALTH SYSTEM - BRUNSWICK CAMPUS	0101000020E610000051D8A8FBFE5E54C0C443B514D22C3F40	2415 PARKWOOD DRIVE	(912) 466-7000	\N
151	SOUTHEAST GEORGIA HEALTH SYSTEM - CAMDEN CAMPUS	0101000020E610000068FBC2F15D6754C0E8EB6436E9C73E40	2000 DAN PROCTOR DRIVE	(912) 576-6401	\N
152	SOUTHEASTERN REGIONAL MEDICAL CENTER	0101000020E6100000F20CF9EB7E3055C00E0F064342B14040	600 CELEBRATE LIFE PARKWAY NORTH	(404) 844-8334	\N
153	SOUTHERN CROSS SURGERY CENTER	0101000020E610000065FACA28BBFF54C0DDD506825BD74040	1301 SIGMAN ROAD NE, SUITE 120	(222) 333-4444	\N
154	SOUTHERN REGIONAL MEDICAL CENTER	0101000020E610000071FBCCF6F41855C0B5E40A521DCA4040	11 UPPER RIVERDALE ROAD SW	(770) 991-8160	\N
155	SOUTHWELL MEDICAL - A CAMPUS OF TRMC	0101000020E6100000B17CA7135ADB54C0ECCFD1ECB21B3F40	260 MJ TAYLOR ROAD	(229) 896-8077	\N
156	ST FRANCIS HOSPITAL - EMORY HEALTHCARE	0101000020E61000004700BBC37B3D55C01E09C93CD1404040	2122 MANCHESTER EXPRESSWAY	(706) 596-4020	\N
157	ST JOSEPH'S HOSPITAL - SAVANNAH	0101000020E610000076A26640E44954C006E3542945FC3F40	11705 MERCY BOULEVARD	(912) 819-4100	\N
158	ST MARY'S GOOD SAMARITAN HOSPITAL	0101000020E6100000156EBF9D80CF54C01F0557929FBD4040	5401 LAKE OCONEE PARKWAY	(706) 453-7331	\N
159	ST MARY'S HOSPITAL	0101000020E6100000B59403A8EFD954C0AABC578C3EF94040	1230 BAXTER STREET	(706) 389-3930	\N
160	ST MARY'S SACRED HEART HOSPITAL, INC	0101000020E61000007B3F032479C854C07064BBCE48384140	367 CLEAR CREEK PARKWAY	(706) 356-7800	\N
161	ST SIMONS - BY THE SEA	0101000020E61000008C7A90B7BF5954C02B71789CFD293F40	2927 DEMERE ROAD	(912) 638-1999	\N
162	STEPHENS COUNTY HOSPITAL	0101000020E61000007AC9DED646D654C0EBAB69E6E24B4140	163 HOSPITAL DRIVE	(706) 282-4250	\N
163	SUMMITRIDGE CENTER - PSYCHIATRY AND ADDICTIVE MED	0101000020E610000054DEF19A55FF54C0C60DE81AA0F84040	250 SCENIC HIGHWAY	(678) 442-5800	\N
164	TANNER MEDICAL CENTER - CARROLLTON	0101000020E61000005A338D81D04455C0AF995BA5E4C84040	705 DIXIE STREET	(770) 836-9580	\N
165	TANNER MEDICAL CENTER VILLA RICA	0101000020E6100000D205EDBCAA3A55C06C12B4B044DF4040	601 DALLAS HIGHWAY	(770) 456-3101	\N
166	TAYLOR REGIONAL HOSPITAL	0101000020E6100000C1065D250CDF54C013C238F21F264040	222 PERRY HWY	(478) 783-0200	\N
167	TIFT REGIONAL MEDICAL CENTER	0101000020E6100000B9CF01B473DF54C0CD31AC24AA783F40	901 E 18TH STREET	(229) 382-7120	\N
168	TURNING POINT HOSPITAL	0101000020E6100000F2B1BB4049F154C0E9263108AC203F40	3015 VETERANS PARKWAY	(229) 985-4815	\N
169	UNION GENERAL HOSPITAL	0101000020E6100000363CBD5296FD54C0287E8CB96B714140	35 HOSPITAL ROAD	(706) 745-2111	\N
170	UNIVERSITY HOSPITAL	0101000020E6100000F5870374E17E54C080BCB2663FBC4040	1350 WALTON WAY	(706) 722-9011	\N
171	UNIVERSITY HOSPITAL MCDUFFIE	0101000020E6100000DEB2BFC31FA054C0E86EF0E8F3C24040	2460 WASHINGTON ROAD	(706) 595-1411	\N
172	UPSON REGIONAL MEDICAL CENTER	0101000020E61000003A3B9D54891555C09002FA3372714040	801 W GORDON STREET	(706) 647-8111	\N
173	VERITAS COLLABORATIVE GEORGIA	0101000020E6100000DE1F8C2B301555C049754BBC4DF64040	41 PERIMETER CENTER EAST, SUITE 400	(770) 871-3750	\N
174	WALTON REHAB HOSPITAL - AFFILIATE OF ENCOMPASS HLTH	0101000020E610000007DC6753BD7E54C06DD71919C3BC4040	1355 INDEPENDENCE DRIVE	(706) 724-7746	\N
175	WARM SPRINGS MEDICAL CENTER	0101000020E61000008B25BC6FC22B55C03AFD4575DF714040	5995 SPRING STREET	(706) 655-9351	\N
176	WASHINGTON COUNTY REGIONAL MEDICAL CENTER	0101000020E6100000C926F1A076B354C07B01CD52787F4040	610 SPARTA ROAD	(478) 240-2100	\N
177	WAYNE MEMORIAL HOSPITAL	0101000020E6100000CAA5121A987954C0E5A59353D8993F40	865 SOUTH FIRST STREET	(912) 530-3302	\N
178	WELLSTAR ATLANTA MEDICAL CENTER	0101000020E6100000D2A92B9FE51755C0D93D7958A8E14040	303 PARKWAY DRIVE NE	(404) 265-4000	\N
179	WELLSTAR COBB HOSPITAL	0101000020E610000001B15BBAB82655C0780C6EEFC3ED4040	3950 AUSTELL RD	(770) 732-4000	\N
180	WELLSTAR DOUGLAS HOSPITAL	0101000020E61000004B6CA949D12E55C05D9E946A9BDE4040	8954 HOSPITAL DRIVE	(770) 949-1500	\N
181	WELLSTAR KENNESTONE HOSPITAL	0101000020E6100000F5415C5A492355C0A8B06BDEE5FB4040	677 CHURCH STREET	(770) 793-5000	\N
182	WELLSTAR NORTH FULTON HOSPITAL	0101000020E61000004D91CF6D7A1455C01045BBE91A084140	3000 HOSPITAL BOULEVARD	(770) 751-2500	\N
183	WELLSTAR PAULDING HOSPITAL	0101000020E6100000C0A5CE69F73155C0748A9F104BF34040	2518 JIMMY LEE SMITH PARKWAY	(470) 644-7000	\N
184	WELLSTAR SPALDING REGIONAL HOSPITAL	0101000020E6100000E63A32FB211155C043089F189F9E4040	601 SOUTH 8TH STREET	(770) 228-2721	\N
185	WELLSTAR SYLVAN GROVE HOSPITAL	0101000020E6100000A8E2841194FE54C0265DC85DE3A64040	1050 MCDONOUGH ROAD	(770) 775-7861	\N
186	WELLSTAR WEST GEORGIA MEDICAL CENTER	0101000020E6100000D9E54282B54355C01E41BF290B844040	1514 VERNON ROAD	(706) 882-1411	\N
187	WELLSTAR WINDY HILL HOSPITAL	0101000020E610000017CD6F3DAF1E55C0732098612BF34040	2540 WINDY HILL ROAD	(770) 644-1081	\N
188	WEST CENTRAL GEORGIA REGIONAL HOSPITAL	0101000020E61000004EAC9D72963755C0F8DF8C92BE3E4040	3000 SCHATULGA RD, PO BOX 12435	(706) 568-5203	\N
189	WILLINGWAY HOSPITAL	0101000020E6100000F5FB59877E7054C082531F48DE384040	311 JONES MILL ROAD	(912) 764-6236	\N
190	WILLS MEMORIAL HOSPITAL	0101000020E61000000A5EDB7883AF54C0DE9A8DF842DD4040	120 GORDON STREET	(706) 678-9212	\N
191	ATLANTA VA MEDICAL CENTER	0101000020E6100000098A1F63EE1355C00C789961A3E64040	1670 CLAIRMONT ROAD	(404) 321-6111	\N
192	CHARLIE NORWOOD DEPARTMENT OF VETERANS AFFAIRS MEDICAL CENTER	0101000020E6100000013274ECA08154C063997E8978BB4040	950 15TH STREET	(706) 733-0188	\N
193	CHARLTON MEMORIAL HOSPITAL	0101000020E6100000CD293BDC528054C06E5D20F763D83E40	2449 THIRD STREET	NOT AVAILABLE	\N
194	BROWN MEMORIAL CONVALESCENT CENTER	0101000020E6100000C491493E9DC754C06DDD518C41244140	545 COOK STREET	(706) 245-1900	\N
195	STEWART WEBSTER HOSPITAL	0101000020E6100000FB27B0E7482A55C02CCDD68F070B4040	580 ALSTON STREET	(229) 887-3366	\N
196	WEST PACES MEDICAL CENTER	0101000020E61000000AEF3866551B55C02C772CD7D7EB4040	3200 HOWELL MILL ROAD	(404) 351-0351	\N
197	YOUTH VILLAGES - INNER HARBOUR CAMPUS	0101000020E6100000818CA989F82E55C0278EF282BED64040	4685 DORSETT SHOALS ROAD	(770) 489-0406	\N
198	EMORY UNIVERSITY HOSPITAL - WESLEY WOODS GERIATRIC HOSPITAL	0101000020E610000032F11ED2351555C0A900CE4106E74040	1821 CLIFTON ROAD, NE	NOT AVAILABLE	\N
199	SOUTHERN CRESCENT HOSPITAL FOR SPECIALTY CARE	0101000020E61000002A317491E71855C02D115E7127CA4040	11 UPPER RIVERDALE ROAD SW	NOT AVAILABLE	\N
200	MIDTOWN MEDICAL CENTER WEST	0101000020E61000002D69BDC60B3F55C0B3951B35743D4040	616 19TH STREET	(706) 494-4262	\N
201	MOUNTAIN LAKES MEDICAL CENTER	0101000020E6100000845183488ADA54C021B159051C714140	196 RIDGECREST CIRCLE	NOT AVAILABLE	\N
202	EMORY UNIVERSITY HOSPITAL	0101000020E610000004D020EC311555C04B33C44E04E74040	1821 CLIFTON ROAD NE	NOT AVAILABLE	\N
203	SOUTHWEST GEORGIA REGIONAL MEDICAL	0101000020E6100000A5E9FD90C83255C096D8CE5A7EC63F40	361 RANDOLPH STREET	NOT AVAILABLE	\N
204	PHOEBE NORTH	0101000020E6100000153115B0D70A55C0693267A6499B3F40	2000 PALMYRA ROAD	(229) 434-2000	\N
205	EAST CENTRAL REGIONAL HOSPITAL - GRACEWOOD	0101000020E6100000F931E6AEE58154C0591D526F3AAF4040	100 MYRTLE BOULEVARD	NOT AVAILABLE	\N
206	CHILDREN'S HOSPITAL NAVICENT HEALTH	0101000020E610000021C3F032BFE854C0B562C966D86A4040	888 PINE STREET	(478) 633-5437	\N
207	RINCON MEDICAL CENTER	0101000020E610000032B15472E94D54C0A617AD8A0D214040	119 CHIMNEY ROAD	(912) 295-5560	\N
208	WELLSTAR ATLANTA MEDICAL CENTER , INC	0101000020E61000009AC8503E521B55C0086CB52413D74040	1170 CLEVELAND AVE	NOT AVAILABLE	\N
209	MORGAN MEMORIAL HOSPITAL	0101000020E61000008E1F4B9BC1DE54C0F9096F28DFCA4040	1077 SOUTH MAIN STREET	NOT AVAILABLE	\N
210	LAKE BRIDGE BEHAVIORAL HEALTH SYSTEM	0101000020E6100000A6A6F2B0AFEB54C06672A412A2724040	3500 RIVERSIDE DRIVE	NOT AVAILABLE	\N
211	COLISEUM PSYCHIATRIC HOSPITAL	0101000020E6100000B7E098A7ABE754C08B6EDEB4706C4040	340 HOSPITAL DRIVE	(478) 765-7000	\N
212	CARL VINSON VA MEDICAL CENTER	0101000020E6100000532E43D25DBC54C01988E96BAB444040	1826 VETERANS BLVD	(478) 272-1210	\N
213	TRINITY HOSPITAL OF AUGUSTA	0101000020E610000066B8A6E52C8154C027399A029DBB4040	2260 WRIGHTSBORO ROAD	(706) 481-7000	\N
214	HILLSIDE HOSPITAL	0101000020E6100000E5FA0CE2621755C0F368B2983BE54040	690 COURTENAY DRIVE NE	(404) 875-4551	\N
215	CALHOUN MEMORIAL HOSPITAL	0101000020E610000051D913D12D2E55C0A3E118F29D6F3F40	55 R E JENNINGS AVE SE	NOT AVAILABLE	\N
216	COOK MEDICAL CENTER	0101000020E61000000A09BDA32BDB54C0A58C8F8102253F40	706 NORTH PARRISH AVENUE	(229) 896-8077	\N
217	WILDWOOD LIFESTYLE CENTER AND HOSPITAL	0101000020E610000039C63E96B85955C0B46D2076897D4140	435 LIFESTYLE LANE	NOT AVAILABLE	\N
218	NORTH GEORGIA MEDICAL CENTER	0101000020E610000023C4117B931F55C0AEC7331EDB564140	1362 SOUTH MAIN STREET	NOT AVAILABLE	\N
219	PRIDE MEDICAL	0101000020E6100000246B05346E1B55C0499EEBFBF0EB4040	3280 HOWELL MILL ROAD NW	(404) 355-3788	\N
220	SOUTHWESTERN STATE HOSPITAL	0101000020E6100000B3B6C6F39BFF54C06AD8B5DEEBCE3E40	400 SOUTH PINE TREE BLVD	NOT AVAILABLE	\N
221	SGMC SMITH NORTHVIEW HOSPITAL	0101000020E6100000D45271CA79D554C0ED53E1110DE63E40	4280 NORTH VALDOSTA ROAD	(229) 433-8000	\N
222	NORTHRIDGE MEDICAL CENTER	0101000020E61000007868923704DE54C037789940151C4140	70 MEDICAL CENTER DRIVE	NOT AVAILABLE	\N
223	TY COBB HEALTHCARE SYSTEM - HART COUNTY HOSPITAL	0101000020E6100000BD3F185720BC54C05930968E5E2C4140	GIBSON AND CADE STREETS	(706) 356-7800	\N
224	GLANCYREHABILITATION HOSPITAL	0101000020E61000000A89EE38C90955C058FC4BF7DF004140	3215 MCCLURE BRIDGE ROAD	NOT AVAILABLE	\N
225	DEVEREUX FOUNDATION, INC.	0101000020E61000000B063A07CD2655C02EC48FD63DFE4040	1291 STANLEY ROAD NW	(770) 427-0147	\N
226	EMORY DUNWOODY MEDICAL CENTER	0101000020E61000003D2122D2C21355C0A2DE842967F64040	4500 NORTH SHALLOWFORD ROAD	(404) 778-6920	\N
227	BRADLEY CENTER OF SAINT FRANCIS	0101000020E6100000978F6288F53D55C06AF87900C93D4040	2000 SIXTEENTH AVENUE	(706) 320-3700	\N
228	NORTHEAST GEORGIA MEDICAL CENTER INC.	0101000020E6100000FDF675E09CF554C0CEFE40B96D0F4140	1400 RIVER PLACE	(770) 848-8000	\N
229	HUGHES SPALDING CHILDRENS HOSP	0101000020E6100000607825C9731855C0E84A04AA7FE04040	35 JESSE HILL JR DR SE	(404) 785-5437	\N
\.


--
-- Name: flood_zones_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.flood_zones_id_seq', 121, true);


--
-- Name: hospitals_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.hospitals_id_seq', 229, true);


--
-- PostgreSQL database dump complete
--

