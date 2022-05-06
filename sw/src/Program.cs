// MIT License
//
// Copyright (c) 2022 Edward Sherriff
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.

using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.IO;
using System.Collections;

namespace praxis
{
    class Program
    {
        private static string[] inputSrc;
        private static string[] lst;
        private static List<unpackedLine> workingBuffer = new List<unpackedLine>();
        private static Hashtable mnemonicHashtable = new Hashtable();
        private static Hashtable labelHashtable = new Hashtable();
        private static UInt64[] opcode;
        const char SPACE = ' ';

        public class Opcode
        {
            public UInt64 op;
            public int operandType;
            public int opShift;
            public Opcode(uint instr, uint operand, int opType, int shift)
            {
                this.op = instr;
                this.op <<= 29;
                this.op |= operand;
                this.opShift = shift;
                this.operandType = opType;
            }
        }


        private static bool FirstPass()
        {
            int i = 0;
            string[] line;
            int j = 0;
            string word;
            bool error = false;
            bool comment = false;
            int lineN;
            int op_count = 0;
            for (i = 0; i < inputSrc.Length; i++)
            {
                lineN = i + 1;
                inputSrc[i] = inputSrc[i].ToUpper();
                line = inputSrc[i].Split(new Char[] {' ','\t'});
                j = 0;
                comment = false;
                workingBuffer.Add(new unpackedLine(i));
                while ((inputSrc[i] != "") && (j < line.Length))
                {
                    while ((j < line.Length) && (line[j].Length == 0))
                    {
                        j++;
                    }
                    if(j == line.Length)
                        break;
                    word = line[j];
                    if (word == "")
                    {
                        break;
                    }
                    switch (word[0])
                    { 
                        case '.':
                            if (workingBuffer[i].directive == "")
                            {
                                workingBuffer[i].directive = word;
                            }
                            else
                            {
                                Console.WriteLine("Multiple directives in line " + lineN);
                                error = true;
                            }
                            break;
                        case '@':
                            if (workingBuffer[i].label == "")
                            {
                                word = word.Remove(0, 1);
                                workingBuffer[i].label = word;
                                if(labelHashtable.Contains(word))
                                {
                                    Console.WriteLine("Dupilcate label " + word + " on line " + lineN);
                                    error = true;
                                }
                                else
	                            {
                                    labelHashtable.Add(word, op_count);
                            	}
                            }
                            else
                            {
                                Console.WriteLine("Multiple labels in line " + lineN);
                                error = true;
                            }
                            break;
                        case ';':
                            comment = true;
                            break;
                        default:
                            if (workingBuffer[i].mnemonic == "")
                            {
                                if (mnemonicHashtable.Contains(word))
                                {
                                    op_count++;
                                    workingBuffer[i].mnemonic = word;
                                }
                                else
                                {
                                    Console.WriteLine("Error no valid mnemonic on line " + lineN);
                                    error = true;    
                                }
                            }
                            else
                            {
                                if (mnemonicHashtable.Contains(word))
                                {
                                    Console.WriteLine("Error duplicate mnemonic on line " + lineN);
                                    error = true;
                                }
                                else
                                {
                                    workingBuffer[i].operands.Add(new operand(word));
                                }
                            }
                            break;
                    }
                    j++;
                    if (error || comment)
                    {
                        break;
                    }
                    if (workingBuffer[i].directive == ".EQU")
                    {
                        if (line.Length < 3)
                        {
                            Console.WriteLine("Invalid equate on line " + lineN);
                            break;
                        }
                        word = line[1];
                        bool equateError = false;
                        switch (word[0])
                        { 
                            case '0':
                                equateError = true;
                                break;
                            case '1':
                                equateError = true;
                                break;
                            case '2':
                                equateError = true;
                                break;
                            case '3':
                                equateError = true;
                                break;
                            case '4':
                                equateError = true;
                                break;
                            case '5':
                                equateError = true;
                                break;
                            case '6':
                                equateError = true;
                                break;
                            case '7':
                                equateError = true;
                                break;
                            case '8':
                                equateError = true;
                                break;
                            case '9':
                                equateError = true;
                                break;
                            case ';':
                                equateError = true;
                                break;
                            case '.':
                                equateError = true;
                                break;
                            case '@':
                                equateError = true;
                                break;
                            case '+':
                                equateError = true;
                                break;
                            case '-':
                                equateError = true;
                                break;
                            case '/':
                                equateError = true;
                                break;
                            case '*':
                                equateError = true;
                                break;
                            case '~':
                                equateError = true;
                                break;
                            case '&':
                                equateError = true;
                                break;
                            case '|':
                                equateError = true;
                                break;
                            case '#':
                                equateError = true;
                                break;
                        }
                        if (equateError)
                        {
                            Console.WriteLine("Invalid equate on line " + lineN);
                            error = true;
                        }
                        else
                        {
                            word = line[2];
                            try
                            {
                                int equateValue;
                                if(word[0] == '$')
                                {
                                    word = word.Remove(0, 1);
                                    equateValue = Int32.Parse(word, System.Globalization.NumberStyles.HexNumber);
                                }
                                else
                                {
                                   equateValue = Int32.Parse(word);
                                }
                                if(mnemonicHashtable.Contains(line[1]))
                                {
                                    Console.WriteLine("Reserved word in equate on line " + lineN);
                                    error = true;
                                }
                                else
                                {
                                    if (labelHashtable.Contains(line[1]))
                                    {
                                        Console.WriteLine("Duplicate label or equate on line " + lineN);
                                        error = true;
                                    }
                                    else
                                    {
                                        labelHashtable.Add(line[1], equateValue);
                                    }
                                }
                            }
                            catch(FormatException)
                            {
                                Console.WriteLine("Invalid value for equate on line " + lineN);
                                error = true;
                            }
                        }
                        break;
                    }
                }
                if ((workingBuffer[i].label != "") && (workingBuffer[i].mnemonic == ""))
                {
                    Console.WriteLine("Error no mnemonic for label " + workingBuffer[i].label);
                    error = true;
                }
            }
            return error;
        }

        static private int SecondPass()
        {
            bool error = false;
            int i;
            int temp;
            opcode = new UInt64[workingBuffer.Count];
            lst = new string[workingBuffer.Count];
            uint operand = 0;
            string word = "";
            int outputCount = 0;
            Opcode code;
            int max = 1;
            for (i = 0; i < workingBuffer.Count; i++)
            {
                operand = 0;
                if(mnemonicHashtable.Contains(workingBuffer[i].mnemonic))
                {
                    code = (Opcode)mnemonicHashtable[workingBuffer[i].mnemonic];
                    opcode[outputCount] = code.op;
                    max = (1 << code.operandType);
                    if (code.operandType == 0)
                    {
                        if (workingBuffer[i].label == "")
                        {
                            lst[outputCount] = "\t\t\t" + workingBuffer[i].mnemonic;
                        }
                        else
                        {
                            lst[outputCount] = "@" + workingBuffer[i].label + "\t\t" + workingBuffer[i].mnemonic;
                        }
                    }
                    else
                    {
                        word = workingBuffer[i].operands[0].str;
                        if (workingBuffer[i].label == "")
                        {
                            lst[outputCount] = "\t\t\t" + workingBuffer[i].mnemonic + "\t\t" + word;
                        }
                        else
                        {
                            lst[outputCount] = "@" + workingBuffer[i].label + "\t\t" + workingBuffer[i].mnemonic + "\t\t" + word;
                        }
                    }
                    try
                    {
                        if (code.operandType != 0)
                        {
                            if (word[0] == '$')
                            {
                                word = word.Remove(0, 1);
                                operand = UInt32.Parse(word, System.Globalization.NumberStyles.HexNumber);
                                if ((code.operandType != 32) && (operand >= max))
                                    operand -= (uint)max * 2;
                            }
                            else
                            {
                                temp = Int32.Parse(word);
                                operand = (uint)temp;
                                if ((code.operandType != 32) && ((temp >= max) || (temp < -max)))
                                    throw new Exception();
                            }
                        }
                    }
                    catch (FormatException)
                    {
                        if (labelHashtable.Contains(word))
                        {
                            if (workingBuffer[i].mnemonic[0] == 'B') // relative branch
                            {
                                operand = (uint)((int)labelHashtable[word]);
                                operand = (operand - (uint)outputCount - 1); // apply a -1 offset to account for the branch delay slot
                                operand &= (uint)(max-1);
                            }
                            else
                            {
                                operand = (uint)((int)labelHashtable[word]);
                                if(code.operandType != 32)
                                    operand &= (uint)(max-1);
                            }
                        }
                        else
                        {
                            Console.WriteLine("Could not parse operand on line " + (workingBuffer[i].line+1).ToString());
                            error = true;
                        }
                    }
                    catch (Exception)
                    {
                        Console.WriteLine("Operand out of range on line " + (workingBuffer[i].line+1).ToString());
                        error = true;
                    }
                    if (code.operandType != 0)
                    {
                        operand <<= code.opShift;
                        opcode[outputCount] = (ulong)((long)opcode[outputCount] + (long)((ulong)operand));
                    }
                    outputCount++;
                }
            }
            if (!error)
            {
                return outputCount;
            }
            else
            {
                return -1;
            }
        }

        static void Main(string[] args)
        {
            if (args.Length < 2)
            {
                Console.WriteLine("Usage: praxis.exe inputfile PM_WIDTH");
            }
            else
            {
                int pm_bits = 0;
                int pm_size = 0;
                bool error = false;
                try
                {
                    if ((pm_bits > 32) && (pm_bits > 2))
                        throw new OverflowException();
                    pm_bits = Int32.Parse(args[1]);
                    pm_size = 1 << pm_bits;
                }
                catch (FormatException)
                {
                    Console.WriteLine("Invalid arguments: PM_WIDTH could not be parsed");
                    error = true;
                }
                catch (OverflowException)
                {
                    Console.WriteLine("Invalid arguments: PM_WIDTH must be between 2 and 32");
                    error = true;
                }
                if (!error)
                {
                    
                    mnemonicHashtable.Add("ADD", new Opcode(0, 0, 29, 0));
                    mnemonicHashtable.Add("ADD#", new Opcode(1, 0, 29, 0));
                    mnemonicHashtable.Add("SUB", new Opcode(4, 0, 29, 0));
                    mnemonicHashtable.Add("SUB#", new Opcode(5, 0, 29, 0));
                    mnemonicHashtable.Add("BUSR", new Opcode(8, 0, 32, 0));
                    mnemonicHashtable.Add("BUSRB0", new Opcode(8, 0x10000000, 28, 0));
                    mnemonicHashtable.Add("BUSRB1", new Opcode(9, 0, 28, 0));
                    mnemonicHashtable.Add("BUSRH0", new Opcode(9, 0x10000000, 28, 0));
                    mnemonicHashtable.Add("BUSRB2", new Opcode(10, 0, 28, 0));
                    mnemonicHashtable.Add("BUSRB3", new Opcode(12, 0, 28, 0));
                    mnemonicHashtable.Add("BUSRH1", new Opcode(14, 0, 28, 0));
                    mnemonicHashtable.Add("BUSRW", new Opcode(15, 0x10000000, 28, 0));
                    mnemonicHashtable.Add("ILD#", new Opcode(16, 0, 32, 0));
                    mnemonicHashtable.Add("LD#", new Opcode(24, 0, 32, 0));
                    mnemonicHashtable.Add("LD", new Opcode(32, 0, 29, 0));
                    mnemonicHashtable.Add("AND", new Opcode(34, 0, 29, 0));
                    mnemonicHashtable.Add("OR", new Opcode(36, 0, 29, 0));
                    mnemonicHashtable.Add("XOR", new Opcode(38, 0, 29, 0));
                    mnemonicHashtable.Add("OUT", new Opcode(40, 0, 16, 0));
                    mnemonicHashtable.Add("IN", new Opcode(44, 0, 16, 0));
                    mnemonicHashtable.Add("ST", new Opcode(48, 0, 29, 0));
                    mnemonicHashtable.Add("IST", new Opcode(52, 0, 29, 0));
                    mnemonicHashtable.Add("ILD", new Opcode(56, 0, 29, 0));
                    mnemonicHashtable.Add("BUSW", new Opcode(64, 0, 32, 0));
                    mnemonicHashtable.Add("BUSWB0", new Opcode(64, 0x10000000, 28, 0));
                    mnemonicHashtable.Add("BUSWB1", new Opcode(65, 0, 28, 0));
                    mnemonicHashtable.Add("BUSWH0", new Opcode(65, 0x10000000, 28, 0));
                    mnemonicHashtable.Add("BUSWB2", new Opcode(66, 0, 28, 0));
                    mnemonicHashtable.Add("BUSWB3", new Opcode(68, 0, 28, 0));
                    mnemonicHashtable.Add("BUSWH1", new Opcode(70, 0, 28, 0));
                    mnemonicHashtable.Add("BUSWW", new Opcode(71, 0x10000000, 28, 0));
                    mnemonicHashtable.Add("IADD#", new Opcode(72, 0, 16, 16));
                    mnemonicHashtable.Add("SHR0", new Opcode(80, 0, 0, 0));
                    mnemonicHashtable.Add("SHR1", new Opcode(81, 0, 0, 0));
                    mnemonicHashtable.Add("SHRX", new Opcode(82, 0, 0, 0));
                    mnemonicHashtable.Add("ROR", new Opcode(83, 0, 0, 0));
                    mnemonicHashtable.Add("SHL0", new Opcode(84, 0, 0, 0));
                    mnemonicHashtable.Add("SHL1", new Opcode(85, 0, 0, 0));
                    mnemonicHashtable.Add("SHLX", new Opcode(86, 0, 0, 0));
                    mnemonicHashtable.Add("ROL", new Opcode(87, 0, 0, 0));
                    mnemonicHashtable.Add("JAL", new Opcode(88, 0, 16, 0));
                    mnemonicHashtable.Add("LDI", new Opcode(96, 0, 16, 0));
                    mnemonicHashtable.Add("ANDI", new Opcode(98, 0, 16, 0));
                    mnemonicHashtable.Add("ORI", new Opcode(100, 0, 16, 0));
                    mnemonicHashtable.Add("XORI", new Opcode(102, 0, 16, 0));
                    mnemonicHashtable.Add("POP", new Opcode(104, 0x10000, 0, 0)); // w = 1
                    mnemonicHashtable.Add("PUSH", new Opcode(108, 0x1FFFFFFF, 0, 0)); // w = -1, y = -1
                    mnemonicHashtable.Add("BRA", new Opcode(112, 0, 29, 0));
                    mnemonicHashtable.Add("BR", new Opcode(112, 0, 29, 0));
                    mnemonicHashtable.Add("BRZ", new Opcode(113, 0, 29, 0));
                    mnemonicHashtable.Add("BRNZ", new Opcode(114, 0, 29, 0));
                    mnemonicHashtable.Add("BRP", new Opcode(115, 0, 29, 0));
                    mnemonicHashtable.Add("BRN", new Opcode(116, 0, 29, 0));
                    mnemonicHashtable.Add("BRIN", new Opcode(117, 0, 29, 0));
                    mnemonicHashtable.Add("BRIO", new Opcode(118, 0, 29, 0));
                    mnemonicHashtable.Add("NOP", new Opcode(119, 0, 0, 0));
                    mnemonicHashtable.Add("STI", new Opcode(120, 0, 16, 0));
                    try
                    {
                        inputSrc = File.ReadAllLines(args[0]);
                    }
                    catch (ArgumentException)
                    {
                        Console.WriteLine("Error, could not open file, path string contains invalid characters.");
                        error = true;
                    }
                    catch (DirectoryNotFoundException)
                    {
                        Console.WriteLine("Error, could not open file, folder path is invalid.");
                        error = true;
                    }
                    catch (IOException e)
                    {
                        Console.WriteLine("Error, could not open file, " + e.ToString());
                        error = true;
                    }
                    if (!error)
                    {
                        Console.WriteLine();
                        Console.WriteLine("Beginning first pass...");
                        if (!FirstPass())
                        {
                            Console.WriteLine("Beginning second pass...");
                            int count = SecondPass();
                            if (count > 0)
                            {
                                if (count < pm_size)
                                {
                                    try
                                    {
                                        TextWriter writer = new StreamWriter("praxos_application_image.vhd");
                                        StringBuilder line = new StringBuilder();
                                        string tmp;
                                        int j;
                                        writer.WriteLine("library ieee;");
                                        writer.WriteLine("use ieee.std_logic_1164.all;");
                                        writer.WriteLine();
                                        writer.WriteLine("-- Praxos ROM content");
                                        writer.WriteLine();
                                        writer.WriteLine("package praxos_application_image is");
                                        writer.WriteLine();
                                        writer.WriteLine("\ttype application_image_t is array(0 to (2**" + pm_bits.ToString() + ")-1) of std_logic_vector(35 downto 0);");
                                        writer.WriteLine("\tconstant application_image : application_image_t := (");
                                        for (int i = 0; i < count; i++)
                                        {
                                            line.AppendFormat("\t\t{0} => X\"",i.ToString());
                                            line.AppendFormat("{0}\", -- {1} {2}",opcode[i].ToString("X9").PadLeft(9,'0'),i,lst[i]);
                                            writer.WriteLine(line.ToString());
                                            line = new StringBuilder();
                                        }
                                        writer.WriteLine("\t\tothers => (others => '0'));");
                                        writer.WriteLine("end praxos_application_image;");
                                        writer.Close();
                                        writer = new StreamWriter("praxos_application_image.mif");
                                        writer.WriteLine("WIDTH=36");
                                        writer.WriteLine("DEPTH=" + pm_bits.ToString() + ";");
                                        writer.WriteLine("ADDRESS_RADIX=UNS");
                                        writer.WriteLine("DATA_RADIX=UNS");
                                        writer.WriteLine("CONTENT BEGIN");
                                        for (int i = 0; i < count; i++)
                                        {
                                            writer.WriteLine(i.ToString() + " : " + opcode[i].ToString() + ";");
                                        }
                                        writer.WriteLine("END;");
                                        writer.Close();
                                        writer = new StreamWriter("praxos_application_image.mem");
                                        for (int i = 0; i < count; i++)
                                        {
                                            writer.WriteLine(opcode[i].ToString("X9").PadLeft(9, '0'));
                                        }
                                        writer.Close();
                                    }
                                    catch (Exception e)
                                    {
                                        Console.WriteLine("Error writing output file: " + e);
                                    }
                                }
                            }
                        }
                    }
                }
            }

        }

        class unpackedLine
        {
            public string label;
            public string directive;
            public string mnemonic;
            public List<operand> operands;
//            public string comment;
            public int line;
            public unpackedLine(int ln)
            {
                line = ln;
                label = "";
                directive = "";
                mnemonic = "";
                operands = new List<operand>();
 //               comment = "";
            }
        }

        class operand
        {
            public string str;
            public operand(string s)
            {
                str = s;
            }
        }
    }
}
