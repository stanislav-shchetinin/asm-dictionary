import subprocess
import os

path = "/home/stas/lp/2/assignment-2-dictionary/main"

class FailedTest:
    def __init__(self, test):
        self.test = test
    def setOutput(self, programOutput):
        self.programOutput = programOutput
        return self
    def setError(self, programError):
        self.programError = programError
        return self

class Test:
    def __init__(self, num):
        self.correctError = ""
        self.correctOutput = ""
        self.num = num
    def setInput(self, testInput):
        self.testInput = testInput
        return self
    def setCorrectOutput(self, correctOutput):
        self.correctOutput = correctOutput
        return self
    def setCorrectError(self, correctError):
        self.correctError = correctError
        return self

tests = [Test(1).setInput("first").setCorrectOutput("first-str"),
        Test(2).setInput("second").setCorrectOutput("second-str"),
        Test(3).setInput("third").setCorrectOutput("third-str"),
        Test(4).setInput("njhu").setCorrectError("----Not found---"),
        Test(5).setInput("").setCorrectError("----Not found---"),
        Test(6).setInput("D"*270).setCorrectError("Strign too large")]

failedTests = []

print("Running " + str(len(tests)) + " tests")
print("----------------------------")

for i in range(len(tests)):

    result = subprocess.Popen([path], stdin = subprocess.PIPE, stdout = subprocess.PIPE, stderr = subprocess.PIPE)
    programOutput, programError = result.communicate(input = tests[i].testInput.encode())

    programOutput = programOutput.decode().strip()
    programError = programError.decode().strip()

    if programOutput == tests[i].correctOutput and programError == tests[i].correctError:
        print("|OK|", end="")
    else:
        print("|WA|", end="")
        failedTests.append(FailedTest(tests[i]).setOutput(programOutput).setError(programError))
print('\n')

if not failedTests:
    print("\nOK")

for currentFailedTest in failedTests:
    print("----------------------------")
    print("Решение упало на тесте №" + str(currentFailedTest.test.num) + ". Ввод: \"" + currentFailedTest.test.testInput + "\"")

    print("Должно быть:")
    if (currentFailedTest.test.correctOutput != ""):
        print("Stdout: ", "\"" + currentFailedTest.test.correctOutput + "\"")
    if (i.test.correctError != ""):
        print("Stdout: ", "\"" + currentFailedTest.test.correctError + "\"")

    print("Программа вывела:")

    if (i.programOutput != ""):
        print("Stdout: ", "\"" + currentFailedTest.programOutput + "\"")
    if (i.programError != ""):
        print("Stdout: ", "\"" + currentFailedTest.programError + "\"")
