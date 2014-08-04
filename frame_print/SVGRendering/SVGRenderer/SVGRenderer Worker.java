package SVGRendering.SVGRenderer;

import java.io.*;
import java.lang.IllegalArgumentException;
import org.apache.batik.transcoder.image.*;
import org.apache.batik.transcoder.TranscoderInput;
import org.apache.batik.transcoder.TranscoderOutput;

public class SVGRendererMultiThread extends SVGRenderer, Thread
{
	private int workerNo = 0;
	
	// Width
	public int width = 1024;
	// Height
	public int height;
	// Output Format
	public String outputFormat = "JPEG";

	// BATIK-SPECIFIC data structures.
	
	// Transcoder object which makes the thing.
	private ImageTranscoder transcoder;
	// Transcoder input
	private TranscoderInput input = new TranscoderInput();
	// Transcoder output
	private TranscoderOutput output = new TranscoderOutput();
	
	// file streams
	
	public void setWorkerNo(int workerNo){
		this.workerNo = workerNo;
	}
	
	public static void main(String args[])
	{
		System.out.printf("Hello\n");		
	}
	
	public String getOuputFormat()
	{
		return this.outputFormat;
	}
	
	public void SetOutputFormat(String format)
	{
		String outputFormatStr = format.toUpperCase();
		
		if (outputFormatStr.equals("JPEG")){
			this.transcoder = new JPEGTranscoder();
			this.outputFormat = "JPEG";
		} else if (outputFormatStr.equals("PNG")) {
			this.transcoder = new PNGTranscoder();
			this.outputFormat = "PNG";			
		} else if (outputFormatStr.equals("TIFF")) {
			this.transcoder = new TIFFTranscoder();
			this.outputFormat = "TIFF";			
		} else {
			throw new IllegalArgumentException("Arguments must be JPEG, PNG, or TIFF\n");
		}
	}
	
	public void SetWidth(int val)
	{
		if (val > 0){
			this.width = val;
		} else{
		throw new IllegalArgumentException("Width must be greater than 0.\n");		
		}
	}
	
	public void RenderImage(String inputFile, String outputFile) throws Exception
	{
		// Create the transcoder input.
		String svgURI = new File(inputFile).toURL().toString();
		this.input.setURI(svgURI);
		
		// Create the transcoder output.		
		OutputStream ostream = new FileOutputStream(outputFile);
		this.output.setOutputStream(ostream);
		
		if (this.outputFormat.equals("JPEG")){
			// Set the transcoding hints.
			this.transcoder.addTranscodingHint(JPEGTranscoder.KEY_QUALITY,
					new Float(1));
			this.transcoder.addTranscodingHint(JPEGTranscoder.KEY_WIDTH,
					new Float(this.width));			

		} else if (this.outputFormat.equals("PNG")){
			this.transcoder.addTranscodingHint(PNGTranscoder.KEY_WIDTH,
				new Float(this.width));							
			
		} else if (this.outputFormat.equals("TIFF")){
		this.transcoder.addTranscodingHint(TIFFTranscoder.KEY_WIDTH,
			new Float(this.width));			
		} else{
		throw new IllegalArgumentException("Invalid Output Format - use SetOutputFormat.\n");			
		} 
		// Save the image.
		this.transcoder.transcode(this.input, this.output);
		
		// Flush and close the stream.
		ostream.flush();
		ostream.close();		
		
		return;
	}
	
	public void run(){
		System.out.printf("Hello from Worker %d\n",this.workerNo);
	}
}

