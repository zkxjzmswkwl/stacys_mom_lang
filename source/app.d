import std.stdio;
import std.conv;
import std.file;
import std.array;
import std.process;
import std.algorithm.searching;
import core.thread;

// This is really bad and is not a language.
// After a few drinks and laughs this came to be.
// I've sobered up now and simply don't find it nearly as funny as I did 6 hours ago, so I'm stopping here.
// Will actually be working on a language at some point in the near future though.

struct Keyword
{
	string stacyKey;
	string inD;
	int inputType;

	string translate(string input)
	{
		return inD.replace("INPUT", input.split("(")[1].split(")")[0]);
	}
}

void displayHelp()
{
	writeln("Commands:");
	writeln("\trun\tRuns .stacy file.\n\t\te.g stacysmom run=hello_world.stacy");
}

string checkArgs(string[] args)
{
	foreach(string arg; args)
	{
		if (canFind(arg, "help"))
			displayHelp();

		if (canFind(arg, "run="))
		{
			// D stdlib function. `run=hello.stacy` ends up being `hello.stacy`.
			arg.skipOver("run=");
			return arg;
		}
	}
	return "";
}

bool isValidRuntime(string firstLine)
{
	if (!canFind(firstLine, "STACYS MOM HAS GOT IT GOING ON | RUNTIME="))
	{
		writeln(".stacy file did not contain valid Stacy header.");
		return false;
	}

	if (canFind(firstLine, "0.1"))
		return true;

	return false;
}

string translateStacy(Keyword*[] keywords, string stacyCode)
{
	string ret = "";

	foreach (string line; stacyCode.split("\n"))
	{
		// Don't need to translate the Stacy header..
		if (canFind(line, "| RUNTIME="))
		{
			continue;
		}

		if (!canFind(line, ";") /*|| !canFind(line, "WAIT_FOR_SO_LONG")*/)
		{
			continue;
		}

		foreach (Keyword* keyword; keywords)
		{
			if (canFind(line, keyword.stacyKey))
				line = keyword.translate(line);
		}

		ret = ret ~ line ~ "\n";
	}

	return ret;
}

string encloseInMain(string input)
{
	return "import std.stdio;\nimport core.thread;\nvoid main() {\n" ~ input ~ "\n}";
}

void main(string[] args)
{
	auto holla 						= new Keyword("HOLLA", "writeln(INPUT);", 1);
	auto wait_for_so_long = new Keyword("WAIT_FOR_SO_LONG", "Thread.sleep(dur!(\"msecs\")(INPUT));", 0);

	string input = checkArgs(args);

	if (input.length == 0)
		return;

	if (!canFind(input, ".stacy"))
		return;

	string stacyCode = readText(input);
	string inputRuntimeVersion = stacyCode.until('\n').to!string();

	if (!isValidRuntime(inputRuntimeVersion))
		return;
	

	string translatedStacy = translateStacy([holla, wait_for_so_long], stacyCode);
	string finalProgram = encloseInMain(translatedStacy);

	File file = File("stacy_output.d", "w");
	file.write(finalProgram);
}
