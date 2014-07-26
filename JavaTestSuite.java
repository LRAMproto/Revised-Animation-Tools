import SVGRendering.SVGRenderer.*;

public class JavaTestSuite{
	public static void main(String args[])
	{
		SVGRenderer renderer = new SVGRenderer();
		System.out.printf("This object outputs to %s.\n",renderer.getOuputFormat());
		return;
	}
	
}

