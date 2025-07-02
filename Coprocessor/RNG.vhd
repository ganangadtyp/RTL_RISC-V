library ieee;
use     ieee.std_logic_1164.all;
use     ieee.numeric_std.all;
use     ieee.std_logic_textio.all;
use     ieee.std_logic_arith.all;

entity RNG is
port(
	clk : in std_logic;
	RNG_out: out std_logic_vector(31 downto 0)
);
end RNG;

architecture behavioral of RNG is 
	signal rng_buf :std_logic_vector(31 downto 0); 
	signal z0, z1, z2, vrm1, v0, vm1, vm2, newv0, newv1, newv0_0, newv0_1, newv0_2 :std_logic_vector(31 downto 0):= (others=>'0');
	signal state_i, pointer_vm1,pointer_vm2, pointer_vrm1 : integer range 0 to 32 := 0;
	type array_seed is array (0 to 15) of std_logic_vector(31 downto 0);
	signal seed : array_seed:= (0 => X"ab23cd77",
								1 => X"89acbdfe",
								2 => X"4a783789",
								3 => X"f2583abc",
								4 => X"b2371def",
								5 => X"a6455eee",
								6 => X"abe62312",
								7 => X"eec7cde3",
								8 => X"e2ad7643",
								9 => X"a3c1e123",
								10 => X"f4a3fefd",
								11 => X"4b52e153",
								12 => X"153acf27",
								13 => X"246bbe53",
								14 => X"57acc313",
								15 => X"3d97aacb");
	begin 
		gen_rng: process(clk)
		begin
		if rising_edge(clk) then
		RNG_out <= rng_buf;
			pointer_vm1 <= ((state_i+13) mod 16);
			pointer_vm2 <= ((state_i+9) mod 16);
			pointer_vrm1 <= ((state_i+15) mod 16);
			v0 <= seed(conv_integer(state_i));
			vm1 <= seed(conv_integer(pointer_vm1));
			vm2 <= seed(conv_integer(pointer_vm2));
			vrm1 <= seed(conv_integer(pointer_vrm1));
			z0 <= vrm1;
			z1(31 downto 16) <= (v0(31 downto 16) xor v0(15 downto 0)) xor (vm1(31 downto 16) xor vm1(16 downto 1));
			z1(15 downto 0) <= (v0(15 downto 0) xor x"0000") xor (vm1(15 downto 0) xor (vm1(0)&"000000000000000"));
			z2(31 downto 16) <= (vm2(31 downto 16) xor ("00000000000" & vm2(31 downto 27)));
			z2(15 downto 0) <=  vm2(15 downto 0) xor vm2(26 downto 11);
			newv1 <= z1 xor z2;
			newv0_0(31 downto 16) <= (z0(31 downto 16) xor z0(29 downto 14)) xor (z1(31 downto 16) xor (z1(13 downto 0)&"00"));
			newv0_0(15 downto 0) <= (z0(15 downto 0) xor (z0(13 downto 0) & "00")) xor (z1(15 downto 0) xor x"0000");
			newv0_1(31 downto 16) <= z2(3 downto 0) & x"000";
			newv0_1(15 downto 0) <= x"0000";
			newv0_2(31 downto 16) <= (newv1(31 downto 16) xor newv1(26 downto 11));
			newv0_2(15 downto 0) <= (newv1(15 downto 0) xor newv1(10 downto 0) & "00000");
			newv0 (31 downto 0) <= (newv0_0 xor newv0_1 xor newv0_2);
			seed(conv_integer(pointer_vrm1)) <= newv0;
			state_i <= (state_i + 15) mod 16;
			rng_buf <= seed(conv_integer(state_i));
		end if;
		end process;
end behavioral;