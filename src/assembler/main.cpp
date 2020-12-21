#include <iostream>
#include <algorithm>
#include <fstream>
#include <vector>
#include <map>
#include <bitset>
using namespace std;

#define IO                               \
  std::ios_base::sync_with_stdio(false); \
  std::cin.tie(NULL);                    \
  std::cout.tie(NULL);

template <size_t N1, size_t N2>
bitset<N1 + N2> concat(const bitset<N1> &b1, const bitset<N2> &b2)
{
  string s1 = b1.to_string();
  string s2 = b2.to_string();
  return bitset<N1 + N2>(s1 + s2);
}

// ==================================
vector<string> code;
map<string, int> labels, variables;
map<string, bitset<16>> noOperand;
map<string, bitset<10>> oneOperand;
// ===================================

// ==============Functions============
bitset<16> compile(string line);

bitset<3> getMode(string &inst);
bitset<3> getRegister(string &inst);

string fetchInst(string &line);
void removeLabel(string &line);

void removeSpacesAndTabs(string &s);
string toUpperCase(string &s);

void getLabelsAndVariables();

void storeLabel(int offset);
void storeVariable(int offset);

string getLabelName(string &s);

bool isLabel(string &s);
bool isVariable(string &s);
bool isNoOperand(string &inst);
bool isOneOperand(string &inst);

// ====================================

void init()
{
  // noOperand init
  noOperand["HLT"] = bitset<16>("0000000000000000");   // 000000
  noOperand["NOP"] = bitset<16>("0000000010100000");   // 000240
  noOperand["RESET"] = bitset<16>("0000000000000101"); // 000005

  // oneOperand init
  oneOperand["INC"] = bitset<10>("0000101010"); // 0052
  oneOperand["DEC"] = bitset<10>("0000101011"); // 0053
  oneOperand["CLR"] = bitset<10>("0000101000"); // 0050
  oneOperand["INV"] = bitset<10>("0000101001"); // 0051
  oneOperand["LSR"] = bitset<10>("0000101111"); // 0057
  oneOperand["ROR"] = bitset<10>("0000110000"); // 0060
  oneOperand["ASR"] = bitset<10>("0000110010"); // 0062
  oneOperand["LSL"] = bitset<10>("0000110011"); // 0063
  oneOperand["ROL"] = bitset<10>("0000110001"); // 0061
}

int main(int argc, char **argv)
{
  IO; // fast IO
  init();

  if (argc != 2)
  {
    cerr << "Invalid arguments, pass the fileName.\n";
    exit(1);
  }

  string fileName = argv[1];

  ifstream inputFile(fileName);
  if (!inputFile.is_open())
  {
    cerr << "Error reading input file.\n";
    exit(1);
  }

  string line;
  while (getline(inputFile, line))
  {
    if (line == "")
      continue; // empty line
    removeSpacesAndTabs(line);
    if (line[0] == ';' || line == "")
      continue;                        // comment or empty line
    code.push_back(toUpperCase(line)); // push to the code vector
  }

  inputFile.close();

  getLabelsAndVariables();

  ofstream outputFile("out.txt");

  bitset<16> inst;
  for (string &line : code)
  {
    inst = compile(line);

    // 1111111111111111 means skip
    if (inst == bitset<16>("1111111111111111"))
      continue;

    outputFile << inst << endl;
  }

  outputFile.close();
}

// ============ Compiler ==============
bitset<16> compile(string line)
{
  bitset<16> skip("1111111111111111");

  // if empty line exit with error
  if (line.empty())
  {
    cerr << "Empty line Error.\n";
    exit(1);
  }

  // line has label
  bool hasLabel = isLabel(line);

  // if line has label remove the label
  if (hasLabel)
  {
    // remove label from line
    removeLabel(line);
    // remove tabs and spaces
    removeSpacesAndTabs(line);
    // if it is a comment skip or empty
    if (line.empty() || line[0] == ';')
      return skip;
  }

  // line has label
  bool hasVariable = isVariable(line);

  // if line has variable skip
  if (hasVariable)
  {
    return skip;
  }

  // get inst from the line
  string instName = fetchInst(line);

  // no operand
  if (isNoOperand(instName))
  {
    return noOperand[instName];
  }

  // one operand
  if (isOneOperand(instName))
  {
    bitset<10> opCode = oneOperand[instName];
    string dst = fetchInst(line);
    bitset<3> mode = getMode(dst);
    bitset<3> reg = getRegister(dst);
    bitset<16> code = concat(opCode, concat(mode, reg));
    return code;
  }

  return skip;
}
// ====================================

bool isNumber(string &s)
{
  return !s.empty() && all_of(s.begin(), s.end(), ::isdigit);
}

bool isLabel(string &s)
{
  return s.find(':') != string::npos;
}

bool isVariable(string &s)
{
  return s.find("DEFINE", 0) != string::npos;
}

bool isNoOperand(string &inst)
{
  return noOperand.count(inst) > 0;
}

bool isOneOperand(string &inst)
{
  return oneOperand.count(inst) > 0;
}

string toUpperCase(string &s)
{
  for (char &c : s)
    if (isalpha(c))
      c = toupper(c);
  return s;
}

void removeSpacesAndTabs(string &s)
{
  int i = 0;
  while (s[i] == '\t' || s[i] == ' ')
    i++;
  if (i)
    s.erase(0, i);
}

void getLabelsAndVariables()
{
  int offset = 0;
  for (string &inst : code)
  {
    if (isLabel(inst))
    {
      storeLabel(offset);
    }
    else if (isVariable(inst))
    {
      storeVariable(offset);
    }

    offset++;
  }
}

void storeLabel(int offset)
{
  string label = getLabelName(code[offset]);
  labels[label] = offset;
}

void storeVariable(int offset)
{
  int i = 6; // skip DEFINE
  string vairable = "", value = "";
  string line = code[offset];
  // skip spaces
  while (i < line.size() && (line[i] == ' ' || line[i] == '\t'))
    i++;
  // get variable name
  while (i < line.size() && (line[i] != ' ' && line[i] != '\t'))
    vairable += line[i++];
  // skip spaces
  while (i < line.size() && (line[i] == ' ' || line[i] == '\t'))
    i++;
  // get value
  while (i < line.size() && (line[i] != ' ' && line[i] != '\t'))
    value += line[i++];

  if (!isNumber(value) || vairable.empty())
  {
    // error
    cerr << "Compilation Error: at " << line << endl;
    exit(1);
  }

  variables[vairable] = stoi(value);
}

string getLabelName(string &s)
{
  string label = "";
  for (char &c : s)
  {
    if (c == ':')
      break;
    label += c;
  }
  return label;
}

string fetchInst(string &line)
{
  removeSpacesAndTabs(line);
  string inst = "";
  int i = 0;
  while (i < line.size() && line[i] != ' ' && line[i] != '\t')
    inst += line[i++];
  line.erase(0, i);
  return inst;
}

bitset<3> getMode(string &inst)
{
  bitset<3> mode;
  if (inst[0] == 'R')
    mode = 0;
  else if (inst[0] == '-')
    mode = 4;
  else if (inst[0] == '(')
    mode = 2;
  else if (isdigit(inst[0]))
    mode = 6;
  else if (inst[0] == '@')
  {
    if (inst[1] == 'R')
      mode = 1;
    else if (inst[1] == '-')
      mode = 5;
    else if (inst[1] == '(')
      mode = 3;
    else if (isdigit(inst[1]))
      mode = 7;
    else
    {
      cerr << "Compilation Error at : " << inst << endl;
      exit(1);
    }
  }
  else
  {
    cerr << "Compilation Error at : " << inst << endl;
    exit(1);
  }

  return mode;
}

bitset<3> getRegister(string &inst)
{
  bitset<3> reg;
  int i = 0;
  while (i < inst.size() && inst[i] != 'R')
    i++;
  if (i + 1 >= inst.size())
  {
    cerr << "Compilation Error at : " << inst << endl;
    exit(1);
  }
  char num = inst[i + 1];
  if (num >= '0' && num <= '7')
    reg = num - '0';
  else
  {
    cerr << "Compilation Error at : " << inst << endl;
    exit(1);
  }
  return reg;
}

void removeLabel(string &line)
{
  int i = 0;
  while (i < line.size() && line[i] != ':')
    i++;
  line.erase(0, i + 1);
}