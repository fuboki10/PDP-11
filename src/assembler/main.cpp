#include <iostream>
#include <algorithm>
#include <fstream>
#include <vector>
#include <map>
using namespace std;

#define IO                               \
  std::ios_base::sync_with_stdio(false); \
  std::cin.tie(NULL);                    \
  std::cout.tie(NULL);

// ==================================
vector<string> code;
map<string, int> labels, variables;
// ===================================

// ==============Functions============
void removeSpacesAndTabs(string &s);
string toUpperCase(string &s);

void getLabelsAndVariables();

void storeLabel(int offset);
void storeVariable(int offset);

string getLabelName(string &s);

bool isLabel(string &s);
bool isVariable(string &s);

// ====================================

int main(int argc, char **argv)
{
  IO; // fast IO

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

  getLabelsAndVariables();
}

bool isNumber(string &s)
{
  return !s.empty() && all_of(s.begin(), s.end(), ::isdigit);
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

bool isLabel(string &s)
{
  return s.find(':') != string::npos;
}

bool isVariable(string &s)
{
  return s.find("DEFINE", 0) != string::npos;
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
