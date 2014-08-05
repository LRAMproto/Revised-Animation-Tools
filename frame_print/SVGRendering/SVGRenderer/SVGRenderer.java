package SVGRendering.SVGRenderer;
import java.util.ArrayList;
import java.io.*;
import java.lang.IllegalArgumentException;
import java.util.InputMismatchException;

import org.apache.batik.transcoder.image.*;
import org.apache.batik.transcoder.TranscoderInput;
import org.apache.batik.transcoder.TranscoderOutput;

public class SVGRenderer extends Thread
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
	
	private int maxNumWorkers = 1;
	
	private ArrayList<String> inputFilenames;
	private ArrayList<String> outputFilenames;	
	
	public static void main(String args[]) throws Exception
	{
		
	}
	
	public String getOuputFormat()
	{
		return this.outputFormat;
	}
	
	public void SetMaxNumWorkers(int val){
		if (val > 0){
			this.maxNumWorkers = val;
		} else{
			throw new IllegalArgumentException("Width must be greater than 0.\n");		
		}		
	}
	
	public void AddFile(String inputFile,String outputFile){
		this.inputFilenames.add(inputFile);		
		this.outputFilenames.add(outputFile);
	}
	
	public void SetOutputFilenames(String[] outputFilenames){
		this.outputFilenames = new ArrayList<String>();		
		for (String filename:outputFilenames){
			//System.out.printf("Adding '%s' to output files.\n",filename);			
 			this.outputFilenames.add(filename);
		}
	}
	
	public void SetInputFilenames(String[] inputFilenames){
		this.inputFilenames = new ArrayList<String>();
		for (String filename:inputFilenames){
			//System.out.printf("Adding '%s' to input files.\n",filename);			
			this.inputFilenames.add(filename);
		}
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
	
	public void SetWorkerNo(int workerNo){
		this.workerNo = workerNo;
	}
	
	
	// Renders as a batch job.
	public void RenderImages(String inputFiles[], String outputFiles[]) throws Exception
	{
		//ArrayList<SVGRenderer> workers = new ArrayList<SVGRenderer>();
		
		if (inputFiles.length != outputFiles.length){
			throw new InputMismatchException();
		}
		
		int numImages = inputFiles.length;
		
		int numWorkers = Math.min(numImages,this.maxNumWorkers);
		
		
		SVGRenderer[] workers = new SVGRenderer[numWorkers];
		//workers = new SVGRenderer[numWorkers];
		
		//SVGRenderer newWorker;
		int filesPerWorker = numImages / numWorkers;
		
		for (int i=0; i<numWorkers; i++){
			workers[i] = new SVGRenderer();
			workers[i].SetWorkerNo(i);
			workers[i].inputFilenames = new ArrayList<String>();
			workers[i].outputFilenames = new ArrayList<String>();
			
		}
		
		int currentWorkerNo;
		
		for (int i=0; i<inputFiles.length; i++){
			currentWorkerNo = i%numWorkers;
			workers[currentWorkerNo].AddFile(inputFiles[i],outputFiles[i]);
		}
		
		/*
		int lastIdx;
		
		int firstToRender = 0;
		int lastToRender = -1;
		int numFilesLeft = numImages;
		int numFilesToRender;

		for (int i=0; i<numWorkers; i++){
			
			firstToRender = lastToRender + 1;			
			numFilesToRender = Math.min(filesPerWorker,numFilesLeft);
			lastToRender = firstToRender + numFilesToRender-1;
			
			String filesToRenderFrom[] = new String[numFilesToRender];
			String filesToRenderTo[] = new String[numFilesToRender];		
			for (int j=firstToRender; j<lastToRender; j++){
				filesToRenderFrom[j] = inputFiles[j];
				filesToRenderTo[j] = inputFiles[j];
			}
		
			workers[i].SetInputFilenames(filesToRenderFrom);
			workers[i].SetOutputFilenames(filesToRenderTo);
			
			numFilesLeft = numFilesLeft-numFilesToRender;
		}
*/
		for (SVGRenderer worker:workers){
			worker.start();
		}
		
		
		for (SVGRenderer worker:workers){
			worker.join();
		}
	}
	
	public void RenderImageBatch() throws Exception
	{
		if (this.inputFilenames == null){
			System.out.printf("Worker %d has nothing to do.\n",this.workerNo);
		} else{
			
			for(int i=0; i<this.inputFilenames.size(); i++){
				//System.out.printf("Rendering %s\n from Worker %d\n to %s\n",this.inputFilenames.get(i),this.workerNo,this.outputFilenames.get(i));		
				this.RenderImage(this.inputFilenames.get(i),this.outputFilenames.get(i));			
			}
		}
	}
	
	public void RenderImage(String inputFile, String outputFile) throws Exception
	{
		// Create the transcoder input.
		String svgURI = new File(inputFile).toURI().toURL().toString();
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
		try{
			this.RenderImageBatch();
		} catch (NullPointerException n){
			System.out.println("Cannot find pointer.\n");
		} catch (Exception e){
			// Do Nothing
			System.out.println("Something went wrong.");
			System.out.println(e.getMessage());			
		}
	}	
	
}

