
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity controller_rom2 is
generic
	(
		ADDR_WIDTH : integer := 15 -- Specify your actual ROM size to save LEs and unnecessary block RAM usage.
	);
port (
	clk : in std_logic;
	reset_n : in std_logic := '1';
	addr : in std_logic_vector(ADDR_WIDTH-1 downto 0);
	q : out std_logic_vector(31 downto 0);
	-- Allow writes - defaults supplied to simplify projects that don't need to write.
	d : in std_logic_vector(31 downto 0) := X"00000000";
	we : in std_logic := '0';
	bytesel : in std_logic_vector(3 downto 0) := "1111"
);
end entity;

architecture rtl of controller_rom2 is

	signal addr1 : integer range 0 to 2**ADDR_WIDTH-1;

	--  build up 2D array to hold the memory
	type word_t is array (0 to 3) of std_logic_vector(7 downto 0);
	type ram_t is array (0 to 2 ** ADDR_WIDTH - 1) of word_t;

	signal ram : ram_t:=
	(

     0 => (x"3e",x"1c",x"00",x"00"),
     1 => (x"00",x"00",x"41",x"63"),
     2 => (x"63",x"41",x"00",x"00"),
     3 => (x"00",x"00",x"1c",x"3e"),
     4 => (x"1c",x"3e",x"2a",x"08"),
     5 => (x"08",x"2a",x"3e",x"1c"),
     6 => (x"3e",x"08",x"08",x"00"),
     7 => (x"00",x"08",x"08",x"3e"),
     8 => (x"e0",x"80",x"00",x"00"),
     9 => (x"00",x"00",x"00",x"60"),
    10 => (x"08",x"08",x"08",x"00"),
    11 => (x"00",x"08",x"08",x"08"),
    12 => (x"60",x"00",x"00",x"00"),
    13 => (x"00",x"00",x"00",x"60"),
    14 => (x"18",x"30",x"60",x"40"),
    15 => (x"01",x"03",x"06",x"0c"),
    16 => (x"59",x"7f",x"3e",x"00"),
    17 => (x"00",x"3e",x"7f",x"4d"),
    18 => (x"7f",x"06",x"04",x"00"),
    19 => (x"00",x"00",x"00",x"7f"),
    20 => (x"71",x"63",x"42",x"00"),
    21 => (x"00",x"46",x"4f",x"59"),
    22 => (x"49",x"63",x"22",x"00"),
    23 => (x"00",x"36",x"7f",x"49"),
    24 => (x"13",x"16",x"1c",x"18"),
    25 => (x"00",x"10",x"7f",x"7f"),
    26 => (x"45",x"67",x"27",x"00"),
    27 => (x"00",x"39",x"7d",x"45"),
    28 => (x"4b",x"7e",x"3c",x"00"),
    29 => (x"00",x"30",x"79",x"49"),
    30 => (x"71",x"01",x"01",x"00"),
    31 => (x"00",x"07",x"0f",x"79"),
    32 => (x"49",x"7f",x"36",x"00"),
    33 => (x"00",x"36",x"7f",x"49"),
    34 => (x"49",x"4f",x"06",x"00"),
    35 => (x"00",x"1e",x"3f",x"69"),
    36 => (x"66",x"00",x"00",x"00"),
    37 => (x"00",x"00",x"00",x"66"),
    38 => (x"e6",x"80",x"00",x"00"),
    39 => (x"00",x"00",x"00",x"66"),
    40 => (x"14",x"08",x"08",x"00"),
    41 => (x"00",x"22",x"22",x"14"),
    42 => (x"14",x"14",x"14",x"00"),
    43 => (x"00",x"14",x"14",x"14"),
    44 => (x"14",x"22",x"22",x"00"),
    45 => (x"00",x"08",x"08",x"14"),
    46 => (x"51",x"03",x"02",x"00"),
    47 => (x"00",x"06",x"0f",x"59"),
    48 => (x"5d",x"41",x"7f",x"3e"),
    49 => (x"00",x"1e",x"1f",x"55"),
    50 => (x"09",x"7f",x"7e",x"00"),
    51 => (x"00",x"7e",x"7f",x"09"),
    52 => (x"49",x"7f",x"7f",x"00"),
    53 => (x"00",x"36",x"7f",x"49"),
    54 => (x"63",x"3e",x"1c",x"00"),
    55 => (x"00",x"41",x"41",x"41"),
    56 => (x"41",x"7f",x"7f",x"00"),
    57 => (x"00",x"1c",x"3e",x"63"),
    58 => (x"49",x"7f",x"7f",x"00"),
    59 => (x"00",x"41",x"41",x"49"),
    60 => (x"09",x"7f",x"7f",x"00"),
    61 => (x"00",x"01",x"01",x"09"),
    62 => (x"41",x"7f",x"3e",x"00"),
    63 => (x"00",x"7a",x"7b",x"49"),
    64 => (x"08",x"7f",x"7f",x"00"),
    65 => (x"00",x"7f",x"7f",x"08"),
    66 => (x"7f",x"41",x"00",x"00"),
    67 => (x"00",x"00",x"41",x"7f"),
    68 => (x"40",x"60",x"20",x"00"),
    69 => (x"00",x"3f",x"7f",x"40"),
    70 => (x"1c",x"08",x"7f",x"7f"),
    71 => (x"00",x"41",x"63",x"36"),
    72 => (x"40",x"7f",x"7f",x"00"),
    73 => (x"00",x"40",x"40",x"40"),
    74 => (x"0c",x"06",x"7f",x"7f"),
    75 => (x"00",x"7f",x"7f",x"06"),
    76 => (x"0c",x"06",x"7f",x"7f"),
    77 => (x"00",x"7f",x"7f",x"18"),
    78 => (x"41",x"7f",x"3e",x"00"),
    79 => (x"00",x"3e",x"7f",x"41"),
    80 => (x"09",x"7f",x"7f",x"00"),
    81 => (x"00",x"06",x"0f",x"09"),
    82 => (x"61",x"41",x"7f",x"3e"),
    83 => (x"00",x"40",x"7e",x"7f"),
    84 => (x"09",x"7f",x"7f",x"00"),
    85 => (x"00",x"66",x"7f",x"19"),
    86 => (x"4d",x"6f",x"26",x"00"),
    87 => (x"00",x"32",x"7b",x"59"),
    88 => (x"7f",x"01",x"01",x"00"),
    89 => (x"00",x"01",x"01",x"7f"),
    90 => (x"40",x"7f",x"3f",x"00"),
    91 => (x"00",x"3f",x"7f",x"40"),
    92 => (x"70",x"3f",x"0f",x"00"),
    93 => (x"00",x"0f",x"3f",x"70"),
    94 => (x"18",x"30",x"7f",x"7f"),
    95 => (x"00",x"7f",x"7f",x"30"),
    96 => (x"1c",x"36",x"63",x"41"),
    97 => (x"41",x"63",x"36",x"1c"),
    98 => (x"7c",x"06",x"03",x"01"),
    99 => (x"01",x"03",x"06",x"7c"),
   100 => (x"4d",x"59",x"71",x"61"),
   101 => (x"00",x"41",x"43",x"47"),
   102 => (x"7f",x"7f",x"00",x"00"),
   103 => (x"00",x"00",x"41",x"41"),
   104 => (x"0c",x"06",x"03",x"01"),
   105 => (x"40",x"60",x"30",x"18"),
   106 => (x"41",x"41",x"00",x"00"),
   107 => (x"00",x"00",x"7f",x"7f"),
   108 => (x"03",x"06",x"0c",x"08"),
   109 => (x"00",x"08",x"0c",x"06"),
   110 => (x"80",x"80",x"80",x"80"),
   111 => (x"00",x"80",x"80",x"80"),
   112 => (x"03",x"00",x"00",x"00"),
   113 => (x"00",x"00",x"04",x"07"),
   114 => (x"54",x"74",x"20",x"00"),
   115 => (x"00",x"78",x"7c",x"54"),
   116 => (x"44",x"7f",x"7f",x"00"),
   117 => (x"00",x"38",x"7c",x"44"),
   118 => (x"44",x"7c",x"38",x"00"),
   119 => (x"00",x"00",x"44",x"44"),
   120 => (x"44",x"7c",x"38",x"00"),
   121 => (x"00",x"7f",x"7f",x"44"),
   122 => (x"54",x"7c",x"38",x"00"),
   123 => (x"00",x"18",x"5c",x"54"),
   124 => (x"7f",x"7e",x"04",x"00"),
   125 => (x"00",x"00",x"05",x"05"),
   126 => (x"a4",x"bc",x"18",x"00"),
   127 => (x"00",x"7c",x"fc",x"a4"),
   128 => (x"04",x"7f",x"7f",x"00"),
   129 => (x"00",x"78",x"7c",x"04"),
   130 => (x"3d",x"00",x"00",x"00"),
   131 => (x"00",x"00",x"40",x"7d"),
   132 => (x"80",x"80",x"80",x"00"),
   133 => (x"00",x"00",x"7d",x"fd"),
   134 => (x"10",x"7f",x"7f",x"00"),
   135 => (x"00",x"44",x"6c",x"38"),
   136 => (x"3f",x"00",x"00",x"00"),
   137 => (x"00",x"00",x"40",x"7f"),
   138 => (x"18",x"0c",x"7c",x"7c"),
   139 => (x"00",x"78",x"7c",x"0c"),
   140 => (x"04",x"7c",x"7c",x"00"),
   141 => (x"00",x"78",x"7c",x"04"),
   142 => (x"44",x"7c",x"38",x"00"),
   143 => (x"00",x"38",x"7c",x"44"),
   144 => (x"24",x"fc",x"fc",x"00"),
   145 => (x"00",x"18",x"3c",x"24"),
   146 => (x"24",x"3c",x"18",x"00"),
   147 => (x"00",x"fc",x"fc",x"24"),
   148 => (x"04",x"7c",x"7c",x"00"),
   149 => (x"00",x"08",x"0c",x"04"),
   150 => (x"54",x"5c",x"48",x"00"),
   151 => (x"00",x"20",x"74",x"54"),
   152 => (x"7f",x"3f",x"04",x"00"),
   153 => (x"00",x"00",x"44",x"44"),
   154 => (x"40",x"7c",x"3c",x"00"),
   155 => (x"00",x"7c",x"7c",x"40"),
   156 => (x"60",x"3c",x"1c",x"00"),
   157 => (x"00",x"1c",x"3c",x"60"),
   158 => (x"30",x"60",x"7c",x"3c"),
   159 => (x"00",x"3c",x"7c",x"60"),
   160 => (x"10",x"38",x"6c",x"44"),
   161 => (x"00",x"44",x"6c",x"38"),
   162 => (x"e0",x"bc",x"1c",x"00"),
   163 => (x"00",x"1c",x"3c",x"60"),
   164 => (x"74",x"64",x"44",x"00"),
   165 => (x"00",x"44",x"4c",x"5c"),
   166 => (x"3e",x"08",x"08",x"00"),
   167 => (x"00",x"41",x"41",x"77"),
   168 => (x"7f",x"00",x"00",x"00"),
   169 => (x"00",x"00",x"00",x"7f"),
   170 => (x"77",x"41",x"41",x"00"),
   171 => (x"00",x"08",x"08",x"3e"),
   172 => (x"03",x"01",x"01",x"02"),
   173 => (x"00",x"01",x"02",x"02"),
   174 => (x"7f",x"7f",x"7f",x"7f"),
   175 => (x"00",x"7f",x"7f",x"7f"),
   176 => (x"1c",x"1c",x"08",x"08"),
   177 => (x"7f",x"7f",x"3e",x"3e"),
   178 => (x"3e",x"3e",x"7f",x"7f"),
   179 => (x"08",x"08",x"1c",x"1c"),
   180 => (x"7c",x"18",x"10",x"00"),
   181 => (x"00",x"10",x"18",x"7c"),
   182 => (x"7c",x"30",x"10",x"00"),
   183 => (x"00",x"10",x"30",x"7c"),
   184 => (x"60",x"60",x"30",x"10"),
   185 => (x"00",x"06",x"1e",x"78"),
   186 => (x"18",x"3c",x"66",x"42"),
   187 => (x"00",x"42",x"66",x"3c"),
   188 => (x"c2",x"6a",x"38",x"78"),
   189 => (x"00",x"38",x"6c",x"c6"),
   190 => (x"60",x"00",x"00",x"60"),
   191 => (x"00",x"60",x"00",x"00"),
   192 => (x"5c",x"5b",x"5e",x"0e"),
   193 => (x"86",x"fc",x"0e",x"5d"),
   194 => (x"f8",x"c2",x"7e",x"71"),
   195 => (x"c0",x"4c",x"bf",x"e4"),
   196 => (x"c4",x"1e",x"c0",x"4b"),
   197 => (x"c4",x"02",x"ab",x"66"),
   198 => (x"c2",x"4d",x"c0",x"87"),
   199 => (x"75",x"4d",x"c1",x"87"),
   200 => (x"ee",x"49",x"73",x"1e"),
   201 => (x"86",x"c8",x"87",x"e3"),
   202 => (x"ef",x"49",x"e0",x"c0"),
   203 => (x"a4",x"c4",x"87",x"ec"),
   204 => (x"f0",x"49",x"6a",x"4a"),
   205 => (x"ca",x"f1",x"87",x"f3"),
   206 => (x"c1",x"84",x"cc",x"87"),
   207 => (x"ab",x"b7",x"c8",x"83"),
   208 => (x"87",x"cd",x"ff",x"04"),
   209 => (x"4d",x"26",x"8e",x"fc"),
   210 => (x"4b",x"26",x"4c",x"26"),
   211 => (x"71",x"1e",x"4f",x"26"),
   212 => (x"e8",x"f8",x"c2",x"4a"),
   213 => (x"e8",x"f8",x"c2",x"5a"),
   214 => (x"49",x"78",x"c7",x"48"),
   215 => (x"26",x"87",x"e1",x"fe"),
   216 => (x"1e",x"73",x"1e",x"4f"),
   217 => (x"b7",x"c0",x"4a",x"71"),
   218 => (x"87",x"d3",x"03",x"aa"),
   219 => (x"bf",x"d8",x"db",x"c2"),
   220 => (x"c1",x"87",x"c4",x"05"),
   221 => (x"c0",x"87",x"c2",x"4b"),
   222 => (x"dc",x"db",x"c2",x"4b"),
   223 => (x"c2",x"87",x"c4",x"5b"),
   224 => (x"fc",x"5a",x"dc",x"db"),
   225 => (x"d8",x"db",x"c2",x"48"),
   226 => (x"c1",x"4a",x"78",x"bf"),
   227 => (x"a2",x"c0",x"c1",x"9a"),
   228 => (x"87",x"e8",x"ec",x"49"),
   229 => (x"4f",x"26",x"4b",x"26"),
   230 => (x"c4",x"4a",x"71",x"1e"),
   231 => (x"49",x"72",x"1e",x"66"),
   232 => (x"fc",x"87",x"e0",x"eb"),
   233 => (x"1e",x"4f",x"26",x"8e"),
   234 => (x"c3",x"48",x"d4",x"ff"),
   235 => (x"d0",x"ff",x"78",x"ff"),
   236 => (x"78",x"e1",x"c0",x"48"),
   237 => (x"c1",x"48",x"d4",x"ff"),
   238 => (x"c4",x"48",x"71",x"78"),
   239 => (x"08",x"d4",x"ff",x"30"),
   240 => (x"48",x"d0",x"ff",x"78"),
   241 => (x"26",x"78",x"e0",x"c0"),
   242 => (x"5b",x"5e",x"0e",x"4f"),
   243 => (x"f4",x"0e",x"5d",x"5c"),
   244 => (x"c8",x"7e",x"c0",x"86"),
   245 => (x"bf",x"ec",x"48",x"a6"),
   246 => (x"c2",x"80",x"fc",x"78"),
   247 => (x"78",x"bf",x"e4",x"f8"),
   248 => (x"bf",x"ec",x"f8",x"c2"),
   249 => (x"4d",x"bf",x"e8",x"4c"),
   250 => (x"bf",x"d8",x"db",x"c2"),
   251 => (x"87",x"de",x"e3",x"49"),
   252 => (x"d6",x"e8",x"49",x"c7"),
   253 => (x"c2",x"49",x"70",x"87"),
   254 => (x"87",x"d0",x"05",x"99"),
   255 => (x"bf",x"d0",x"db",x"c2"),
   256 => (x"c8",x"b9",x"ff",x"49"),
   257 => (x"99",x"c1",x"99",x"66"),
   258 => (x"87",x"fe",x"c1",x"02"),
   259 => (x"cb",x"49",x"e8",x"cf"),
   260 => (x"4b",x"70",x"87",x"ca"),
   261 => (x"f2",x"e7",x"49",x"c7"),
   262 => (x"05",x"98",x"70",x"87"),
   263 => (x"66",x"c8",x"87",x"c9"),
   264 => (x"02",x"99",x"c1",x"49"),
   265 => (x"c8",x"87",x"c3",x"c1"),
   266 => (x"bf",x"ec",x"48",x"a6"),
   267 => (x"d8",x"db",x"c2",x"78"),
   268 => (x"d9",x"e2",x"49",x"bf"),
   269 => (x"ca",x"49",x"73",x"87"),
   270 => (x"98",x"70",x"87",x"ee"),
   271 => (x"c2",x"87",x"d7",x"02"),
   272 => (x"49",x"bf",x"cc",x"db"),
   273 => (x"db",x"c2",x"b9",x"c1"),
   274 => (x"fd",x"71",x"59",x"d0"),
   275 => (x"e8",x"cf",x"87",x"d9"),
   276 => (x"87",x"c8",x"ca",x"49"),
   277 => (x"49",x"c7",x"4b",x"70"),
   278 => (x"70",x"87",x"f0",x"e6"),
   279 => (x"c6",x"ff",x"05",x"98"),
   280 => (x"49",x"66",x"c8",x"87"),
   281 => (x"fe",x"05",x"99",x"c1"),
   282 => (x"db",x"c2",x"87",x"fd"),
   283 => (x"c1",x"4a",x"bf",x"d8"),
   284 => (x"dc",x"db",x"c2",x"ba"),
   285 => (x"7a",x"0a",x"fc",x"5a"),
   286 => (x"c1",x"9a",x"c1",x"0a"),
   287 => (x"e8",x"49",x"a2",x"c0"),
   288 => (x"da",x"c1",x"87",x"fa"),
   289 => (x"87",x"c3",x"e6",x"49"),
   290 => (x"db",x"c2",x"7e",x"c1"),
   291 => (x"66",x"c8",x"48",x"d0"),
   292 => (x"d8",x"db",x"c2",x"78"),
   293 => (x"e9",x"c0",x"05",x"bf"),
   294 => (x"c3",x"49",x"75",x"87"),
   295 => (x"1e",x"71",x"99",x"ff"),
   296 => (x"f3",x"fb",x"49",x"c0"),
   297 => (x"c8",x"49",x"75",x"87"),
   298 => (x"1e",x"71",x"29",x"b7"),
   299 => (x"e7",x"fb",x"49",x"c1"),
   300 => (x"c3",x"86",x"c8",x"87"),
   301 => (x"d2",x"e5",x"49",x"fd"),
   302 => (x"49",x"fa",x"c3",x"87"),
   303 => (x"c7",x"87",x"cc",x"e5"),
   304 => (x"49",x"75",x"87",x"fb"),
   305 => (x"c8",x"99",x"ff",x"c3"),
   306 => (x"b5",x"71",x"2d",x"b7"),
   307 => (x"c0",x"02",x"9d",x"75"),
   308 => (x"a6",x"c8",x"87",x"e5"),
   309 => (x"bf",x"c8",x"ff",x"48"),
   310 => (x"49",x"66",x"c8",x"78"),
   311 => (x"bf",x"d4",x"db",x"c2"),
   312 => (x"a9",x"e0",x"c2",x"89"),
   313 => (x"87",x"c5",x"c0",x"03"),
   314 => (x"d0",x"c0",x"4d",x"c0"),
   315 => (x"d4",x"db",x"c2",x"87"),
   316 => (x"78",x"66",x"c8",x"48"),
   317 => (x"c2",x"87",x"c6",x"c0"),
   318 => (x"c0",x"48",x"d4",x"db"),
   319 => (x"c8",x"49",x"75",x"78"),
   320 => (x"ce",x"c0",x"05",x"99"),
   321 => (x"49",x"f5",x"c3",x"87"),
   322 => (x"70",x"87",x"c0",x"e4"),
   323 => (x"02",x"99",x"c2",x"49"),
   324 => (x"c2",x"87",x"e4",x"c0"),
   325 => (x"02",x"bf",x"e8",x"f8"),
   326 => (x"48",x"87",x"ca",x"c0"),
   327 => (x"f8",x"c2",x"88",x"c1"),
   328 => (x"d0",x"c0",x"58",x"ec"),
   329 => (x"4a",x"66",x"c4",x"87"),
   330 => (x"6a",x"82",x"e0",x"c1"),
   331 => (x"87",x"c5",x"c0",x"02"),
   332 => (x"73",x"49",x"ff",x"4b"),
   333 => (x"75",x"7e",x"c1",x"0f"),
   334 => (x"05",x"99",x"c4",x"49"),
   335 => (x"c3",x"87",x"ce",x"c0"),
   336 => (x"c6",x"e3",x"49",x"f2"),
   337 => (x"c2",x"49",x"70",x"87"),
   338 => (x"ed",x"c0",x"02",x"99"),
   339 => (x"e8",x"f8",x"c2",x"87"),
   340 => (x"c7",x"48",x"7e",x"bf"),
   341 => (x"c0",x"03",x"a8",x"b7"),
   342 => (x"48",x"6e",x"87",x"cb"),
   343 => (x"f8",x"c2",x"80",x"c1"),
   344 => (x"d3",x"c0",x"58",x"ec"),
   345 => (x"48",x"66",x"c4",x"87"),
   346 => (x"70",x"80",x"e0",x"c1"),
   347 => (x"02",x"bf",x"6e",x"7e"),
   348 => (x"4b",x"87",x"c5",x"c0"),
   349 => (x"0f",x"73",x"49",x"fe"),
   350 => (x"fd",x"c3",x"7e",x"c1"),
   351 => (x"87",x"cb",x"e2",x"49"),
   352 => (x"99",x"c2",x"49",x"70"),
   353 => (x"87",x"e6",x"c0",x"02"),
   354 => (x"bf",x"e8",x"f8",x"c2"),
   355 => (x"87",x"c9",x"c0",x"02"),
   356 => (x"48",x"e8",x"f8",x"c2"),
   357 => (x"d3",x"c0",x"78",x"c0"),
   358 => (x"48",x"66",x"c4",x"87"),
   359 => (x"70",x"80",x"e0",x"c1"),
   360 => (x"02",x"bf",x"6e",x"7e"),
   361 => (x"4b",x"87",x"c5",x"c0"),
   362 => (x"0f",x"73",x"49",x"fd"),
   363 => (x"fa",x"c3",x"7e",x"c1"),
   364 => (x"87",x"d7",x"e1",x"49"),
   365 => (x"99",x"c2",x"49",x"70"),
   366 => (x"87",x"ea",x"c0",x"02"),
   367 => (x"bf",x"e8",x"f8",x"c2"),
   368 => (x"a8",x"b7",x"c7",x"48"),
   369 => (x"87",x"c9",x"c0",x"03"),
   370 => (x"48",x"e8",x"f8",x"c2"),
   371 => (x"d3",x"c0",x"78",x"c7"),
   372 => (x"48",x"66",x"c4",x"87"),
   373 => (x"70",x"80",x"e0",x"c1"),
   374 => (x"02",x"bf",x"6e",x"7e"),
   375 => (x"4b",x"87",x"c5",x"c0"),
   376 => (x"0f",x"73",x"49",x"fc"),
   377 => (x"48",x"75",x"7e",x"c1"),
   378 => (x"cc",x"98",x"f0",x"c3"),
   379 => (x"98",x"70",x"58",x"a6"),
   380 => (x"87",x"ce",x"c0",x"05"),
   381 => (x"e0",x"49",x"da",x"c1"),
   382 => (x"49",x"70",x"87",x"d1"),
   383 => (x"c1",x"02",x"99",x"c2"),
   384 => (x"e8",x"cf",x"87",x"ff"),
   385 => (x"87",x"d4",x"c3",x"49"),
   386 => (x"f8",x"c2",x"4b",x"70"),
   387 => (x"50",x"c0",x"48",x"e0"),
   388 => (x"97",x"e0",x"f8",x"c2"),
   389 => (x"d8",x"c1",x"05",x"bf"),
   390 => (x"05",x"66",x"c8",x"87"),
   391 => (x"c1",x"87",x"cd",x"c0"),
   392 => (x"df",x"ff",x"49",x"da"),
   393 => (x"98",x"70",x"87",x"e5"),
   394 => (x"87",x"c5",x"c1",x"02"),
   395 => (x"49",x"4d",x"bf",x"e8"),
   396 => (x"c8",x"99",x"ff",x"c3"),
   397 => (x"b5",x"71",x"2d",x"b7"),
   398 => (x"bf",x"d8",x"db",x"c2"),
   399 => (x"cd",x"da",x"ff",x"49"),
   400 => (x"c2",x"49",x"73",x"87"),
   401 => (x"98",x"70",x"87",x"e2"),
   402 => (x"87",x"c6",x"c0",x"02"),
   403 => (x"48",x"e0",x"f8",x"c2"),
   404 => (x"f8",x"c2",x"50",x"c1"),
   405 => (x"05",x"bf",x"97",x"e0"),
   406 => (x"75",x"87",x"d6",x"c0"),
   407 => (x"99",x"f0",x"c3",x"49"),
   408 => (x"87",x"c8",x"ff",x"05"),
   409 => (x"ff",x"49",x"da",x"c1"),
   410 => (x"70",x"87",x"e0",x"de"),
   411 => (x"fb",x"fe",x"05",x"98"),
   412 => (x"e8",x"f8",x"c2",x"87"),
   413 => (x"cc",x"4b",x"49",x"bf"),
   414 => (x"83",x"66",x"c4",x"93"),
   415 => (x"73",x"71",x"4b",x"6b"),
   416 => (x"02",x"9c",x"74",x"0f"),
   417 => (x"6c",x"87",x"e9",x"c0"),
   418 => (x"87",x"e4",x"c0",x"02"),
   419 => (x"dd",x"ff",x"49",x"6c"),
   420 => (x"49",x"70",x"87",x"f9"),
   421 => (x"c0",x"02",x"99",x"c1"),
   422 => (x"a4",x"c4",x"87",x"cb"),
   423 => (x"e8",x"f8",x"c2",x"4b"),
   424 => (x"4b",x"6b",x"49",x"bf"),
   425 => (x"02",x"84",x"c8",x"0f"),
   426 => (x"6c",x"87",x"c5",x"c0"),
   427 => (x"87",x"dc",x"ff",x"05"),
   428 => (x"c8",x"c0",x"02",x"6e"),
   429 => (x"e8",x"f8",x"c2",x"87"),
   430 => (x"c3",x"f1",x"49",x"bf"),
   431 => (x"26",x"8e",x"f4",x"87"),
   432 => (x"26",x"4c",x"26",x"4d"),
   433 => (x"00",x"4f",x"26",x"4b"),
   434 => (x"00",x"00",x"00",x"10"),
   435 => (x"00",x"00",x"00",x"00"),
   436 => (x"00",x"00",x"00",x"00"),
   437 => (x"00",x"00",x"00",x"00"),
   438 => (x"00",x"00",x"00",x"00"),
   439 => (x"ff",x"4a",x"71",x"1e"),
   440 => (x"72",x"49",x"bf",x"c8"),
   441 => (x"4f",x"26",x"48",x"a1"),
   442 => (x"bf",x"c8",x"ff",x"1e"),
   443 => (x"c0",x"c0",x"fe",x"89"),
   444 => (x"a9",x"c0",x"c0",x"c0"),
   445 => (x"c0",x"87",x"c4",x"01"),
   446 => (x"c1",x"87",x"c2",x"4a"),
   447 => (x"26",x"48",x"72",x"4a"),
   448 => (x"5b",x"5e",x"0e",x"4f"),
   449 => (x"71",x"0e",x"5d",x"5c"),
   450 => (x"4c",x"d4",x"ff",x"4b"),
   451 => (x"c0",x"48",x"66",x"d0"),
   452 => (x"ff",x"49",x"d6",x"78"),
   453 => (x"c3",x"87",x"f1",x"dc"),
   454 => (x"49",x"6c",x"7c",x"ff"),
   455 => (x"71",x"99",x"ff",x"c3"),
   456 => (x"f0",x"c3",x"49",x"4d"),
   457 => (x"a9",x"e0",x"c1",x"99"),
   458 => (x"c3",x"87",x"cb",x"05"),
   459 => (x"48",x"6c",x"7c",x"ff"),
   460 => (x"66",x"d0",x"98",x"c3"),
   461 => (x"ff",x"c3",x"78",x"08"),
   462 => (x"49",x"4a",x"6c",x"7c"),
   463 => (x"ff",x"c3",x"31",x"c8"),
   464 => (x"71",x"4a",x"6c",x"7c"),
   465 => (x"c8",x"49",x"72",x"b2"),
   466 => (x"7c",x"ff",x"c3",x"31"),
   467 => (x"b2",x"71",x"4a",x"6c"),
   468 => (x"31",x"c8",x"49",x"72"),
   469 => (x"6c",x"7c",x"ff",x"c3"),
   470 => (x"ff",x"b2",x"71",x"4a"),
   471 => (x"e0",x"c0",x"48",x"d0"),
   472 => (x"02",x"9b",x"73",x"78"),
   473 => (x"7b",x"72",x"87",x"c2"),
   474 => (x"4d",x"26",x"48",x"75"),
   475 => (x"4b",x"26",x"4c",x"26"),
   476 => (x"26",x"1e",x"4f",x"26"),
   477 => (x"5b",x"5e",x"0e",x"4f"),
   478 => (x"86",x"f8",x"0e",x"5c"),
   479 => (x"a6",x"c8",x"1e",x"76"),
   480 => (x"87",x"fd",x"fd",x"49"),
   481 => (x"4b",x"70",x"86",x"c4"),
   482 => (x"a8",x"c4",x"48",x"6e"),
   483 => (x"87",x"fb",x"c2",x"03"),
   484 => (x"f0",x"c3",x"4a",x"73"),
   485 => (x"aa",x"d0",x"c1",x"9a"),
   486 => (x"c1",x"87",x"c7",x"02"),
   487 => (x"c2",x"05",x"aa",x"e0"),
   488 => (x"49",x"73",x"87",x"e9"),
   489 => (x"c3",x"02",x"99",x"c8"),
   490 => (x"87",x"c6",x"ff",x"87"),
   491 => (x"9c",x"c3",x"4c",x"73"),
   492 => (x"c1",x"05",x"ac",x"c2"),
   493 => (x"66",x"c4",x"87",x"c4"),
   494 => (x"71",x"31",x"c9",x"49"),
   495 => (x"4a",x"66",x"c4",x"1e"),
   496 => (x"c2",x"92",x"cc",x"c1"),
   497 => (x"72",x"49",x"f0",x"f8"),
   498 => (x"dd",x"cc",x"fe",x"81"),
   499 => (x"ff",x"49",x"d8",x"87"),
   500 => (x"c8",x"87",x"f5",x"d9"),
   501 => (x"e5",x"c2",x"1e",x"c0"),
   502 => (x"e5",x"fd",x"49",x"e8"),
   503 => (x"d0",x"ff",x"87",x"f8"),
   504 => (x"78",x"e0",x"c0",x"48"),
   505 => (x"1e",x"e8",x"e5",x"c2"),
   506 => (x"c1",x"4a",x"66",x"cc"),
   507 => (x"f8",x"c2",x"92",x"cc"),
   508 => (x"81",x"72",x"49",x"f0"),
   509 => (x"87",x"f3",x"ca",x"fe"),
   510 => (x"ac",x"c1",x"86",x"cc"),
   511 => (x"87",x"cb",x"c1",x"05"),
   512 => (x"fd",x"49",x"ee",x"c0"),
   513 => (x"c4",x"87",x"c5",x"e2"),
   514 => (x"31",x"c9",x"49",x"66"),
   515 => (x"66",x"c4",x"1e",x"71"),
   516 => (x"92",x"cc",x"c1",x"4a"),
   517 => (x"49",x"f0",x"f8",x"c2"),
   518 => (x"cb",x"fe",x"81",x"72"),
   519 => (x"e5",x"c2",x"87",x"cc"),
   520 => (x"66",x"c8",x"1e",x"e8"),
   521 => (x"92",x"cc",x"c1",x"4a"),
   522 => (x"49",x"f0",x"f8",x"c2"),
   523 => (x"c8",x"fe",x"81",x"72"),
   524 => (x"49",x"d7",x"87",x"fa"),
   525 => (x"87",x"d0",x"d8",x"ff"),
   526 => (x"c2",x"1e",x"c0",x"c8"),
   527 => (x"fd",x"49",x"e8",x"e5"),
   528 => (x"cc",x"87",x"f0",x"e3"),
   529 => (x"48",x"d0",x"ff",x"86"),
   530 => (x"f8",x"78",x"e0",x"c0"),
   531 => (x"26",x"4c",x"26",x"8e"),
   532 => (x"1e",x"4f",x"26",x"4b"),
   533 => (x"b7",x"c4",x"4a",x"71"),
   534 => (x"87",x"ce",x"03",x"aa"),
   535 => (x"cc",x"c1",x"49",x"72"),
   536 => (x"f0",x"f8",x"c2",x"91"),
   537 => (x"81",x"c8",x"c1",x"81"),
   538 => (x"4f",x"26",x"79",x"c0"),
   539 => (x"5c",x"5b",x"5e",x"0e"),
   540 => (x"86",x"fc",x"0e",x"5d"),
   541 => (x"d4",x"ff",x"4a",x"71"),
   542 => (x"d4",x"4c",x"c0",x"4b"),
   543 => (x"b7",x"c3",x"4d",x"66"),
   544 => (x"c2",x"c2",x"01",x"ad"),
   545 => (x"02",x"9a",x"72",x"87"),
   546 => (x"1e",x"87",x"ec",x"c0"),
   547 => (x"cc",x"c1",x"49",x"75"),
   548 => (x"f0",x"f8",x"c2",x"91"),
   549 => (x"c8",x"80",x"71",x"48"),
   550 => (x"66",x"c4",x"58",x"a6"),
   551 => (x"d7",x"c2",x"fe",x"49"),
   552 => (x"70",x"86",x"c4",x"87"),
   553 => (x"87",x"d4",x"02",x"98"),
   554 => (x"c8",x"c1",x"49",x"6e"),
   555 => (x"6e",x"79",x"c1",x"81"),
   556 => (x"69",x"81",x"c8",x"49"),
   557 => (x"75",x"87",x"c5",x"4c"),
   558 => (x"87",x"d7",x"fe",x"49"),
   559 => (x"c8",x"48",x"d0",x"ff"),
   560 => (x"7b",x"dd",x"78",x"e1"),
   561 => (x"ff",x"c3",x"48",x"74"),
   562 => (x"74",x"7b",x"70",x"98"),
   563 => (x"29",x"b7",x"c8",x"49"),
   564 => (x"ff",x"c3",x"48",x"71"),
   565 => (x"74",x"7b",x"70",x"98"),
   566 => (x"29",x"b7",x"d0",x"49"),
   567 => (x"ff",x"c3",x"48",x"71"),
   568 => (x"74",x"7b",x"70",x"98"),
   569 => (x"28",x"b7",x"d8",x"48"),
   570 => (x"7b",x"c0",x"7b",x"70"),
   571 => (x"7b",x"7b",x"7b",x"7b"),
   572 => (x"7b",x"7b",x"7b",x"7b"),
   573 => (x"ff",x"7b",x"7b",x"7b"),
   574 => (x"e0",x"c0",x"48",x"d0"),
   575 => (x"dc",x"1e",x"75",x"78"),
   576 => (x"e8",x"d5",x"ff",x"49"),
   577 => (x"fc",x"86",x"c4",x"87"),
   578 => (x"26",x"4d",x"26",x"8e"),
   579 => (x"26",x"4b",x"26",x"4c"),
   580 => (x"00",x"00",x"00",x"4f"),
   581 => (x"ff",x"ff",x"ff",x"ff"),
   582 => (x"ff",x"ff",x"ff",x"ff"),
   583 => (x"ff",x"ff",x"ff",x"ff"),
   584 => (x"ff",x"ff",x"ff",x"ff"),
   585 => (x"00",x"00",x"29",x"28"),
   586 => (x"33",x"49",x"56",x"53"),
   587 => (x"20",x"20",x"38",x"32"),
   588 => (x"00",x"4d",x"4f",x"52"),
   589 => (x"00",x"00",x"1b",x"f3"),
		others => (others => x"00")
	);
	signal q1_local : word_t;

	-- Altera Quartus attributes
	attribute ramstyle: string;
	attribute ramstyle of ram: signal is "no_rw_check";

begin  -- rtl

	addr1 <= to_integer(unsigned(addr(ADDR_WIDTH-1 downto 0)));

	-- Reorganize the read data from the RAM to match the output
	q(7 downto 0) <= q1_local(3);
	q(15 downto 8) <= q1_local(2);
	q(23 downto 16) <= q1_local(1);
	q(31 downto 24) <= q1_local(0);

	process(clk)
	begin
		if(rising_edge(clk)) then 
			if(we = '1') then
				-- edit this code if using other than four bytes per word
				if (bytesel(3) = '1') then
					ram(addr1)(3) <= d(7 downto 0);
				end if;
				if (bytesel(2) = '1') then
					ram(addr1)(2) <= d(15 downto 8);
				end if;
				if (bytesel(1) = '1') then
					ram(addr1)(1) <= d(23 downto 16);
				end if;
				if (bytesel(0) = '1') then
					ram(addr1)(0) <= d(31 downto 24);
				end if;
			end if;
			q1_local <= ram(addr1);
		end if;
	end process;
  
end rtl;

