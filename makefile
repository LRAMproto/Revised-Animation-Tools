default: tests

all: 

renderer:
	javac -cp SVGRendering/batik-1.7/batik.jar SVGRendering/SVGRenderer/SVGRenderer.java;

tests: renderer
	javac JavaTestSuite.java;

svgrenderingtest: tests
	java -cp SVGRendering/batik-1.7/batik.jar;SVGRendering/SVGRenderer JavaTestSuite
clean:
	rm  *.class SVGRenderer/*.class
