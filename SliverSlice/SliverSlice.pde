// gif animation lib from: http://www.extrapixel.ch/processing/gifAnimation/
// NOTE: don't set color opacity/alpha, or gif will all be black
import gifAnimation.*;
import java.util.*;
import java.io.*;

PImage src;
PImage slice = new PImage();
ArrayList<Slice> slices = new ArrayList<Slice>();
Random generator = new Random();
int sliceSize = 10;
int gifFrames = 0;
final int MAX_GIF_FRAMES = 20;
boolean makingGif = false;
GifMaker gifMaker;


void setup() {
  File imageFile = getRandomJpgInDataFolder();
  if(imageFile==null){
    println("No images in data folder.  Types allowed: .gif, .jpg, .tga, .png ");
    size(600,600);
    randomBoxes();
    crazyness(10);
  } else {
    println("imageFile = " + imageFile.getAbsolutePath());
    src = loadImage(imageFile.getName());
    size(src.width, src.height);
    image(src, 0, 0);
    loadPixels();
  }
  //smooth();
}

void draw() {
  if(makingGif){
    if(gifFrames<MAX_GIF_FRAMES){
      gifMaker.setDelay(5);
      gifMaker.addFrame();  
      gifFrames++;
      crazyness(5);
    } else {
      gifFrames = 0;
      makingGif = false;
      boolean saved = gifMaker.finish(); // write file
      println("saved gif: " + saved);
    }
  }
}

void keyPressed() {
  if (key == 'h') { sliceHorizontal(sliceSize); }
  if (key == 'H') { sliceHorizontalRandom(); }
  if (key == 'v') { sliceVertical(sliceSize); }
  if (key == 'V') { sliceVerticalRandom(); }
  if (key == 'c') { crazyness(10); }
  if (key == 'b') { randomBoxes(); }
  if (key == 'x') { randomBoxes(); crazyness(10); }
  if (key == 'g') { makeGif(); }
  if (key == 'r') { reset(); }
  if (key == ' ') { saveOutput(); }
}

void makeGif(){
  if(makingGif){
    println("currently making a gif");
    return;
  }
  frameRate(12);
  int r = rndi(1000000000);
  gifMaker = new GifMaker(this, "output/" + r + ".gif");
  gifMaker.setRepeat(0);        // make it an "endless" animation
//  gifMaker.setQuality(5);
//  gifMaker.setTransparent(255);
  makingGif = true;
}

void saveOutput(){
  int r = rndi(1000000000);
  String outputName = "output/"+r+".tif";
  save(outputName);
  println("saved "+ outputName);
}

void reset(){
  image(src, 0, 0);
}

void randomBoxes(){
   background(255);
   noStroke();
   int randomR = rndi(155);
   int randomG = rndi(155);
   int randomB = rndi(155);
   for(int i=0;i<30;i++){
     fill(randomR + rndi(100), randomG + rndi(100), randomB + rndi(100));
     rect(random(width*0.5), random(height*0.5), random(width*0.7), random(height*0.7));
   }  
}

int rndi(int max){
  return (int)random(max);
}

void crazyness(int loops){
  for(int i=0;i<loops;i++){
    if(random(10)<5)sliceHorizontal(sliceSize);
    if(random(10)<5)sliceVertical(sliceSize);
    if(random(10)<5)sliceHorizontalRandom();
    if(random(10)<5)sliceVerticalRandom();
  }
}

File getRandomJpgInDataFolder(){
  FilenameFilter fnf = new FilenameFilter(){
    public boolean accept(File f, String name){
      return name.toLowerCase().endsWith(".gif") 
             || name.toLowerCase().endsWith(".jpg")
             || name.toLowerCase().endsWith(".tga")
             || name.toLowerCase().endsWith(".png");
    }
  };

  File dataFolder = new File(sketchPath+File.separator+"data");
  if(!dataFolder.exists()){
    println("create a data folder");
    return null;
  }
  File[] imageFileArray = new File(sketchPath+File.separator+"data").listFiles(fnf);
  println(imageFileArray.length + " images in data folder");
  if(imageFileArray.length == 0){
    return null;
  }
  File imageFile = imageFileArray[floor(random(0,imageFileArray.length))];
  return imageFile;
}

void sliceHorizontalRandom() {
  int currentY = 0;
  while (currentY < height) {
    int randomSliceSize = (int) random(height/5);
    if (randomSliceSize + currentY > height) randomSliceSize = height - currentY;
    slice = get(0, currentY, width, randomSliceSize);
    slices.add(new Slice(slice));
    currentY += randomSliceSize;
  }
  currentY = 0;
  Collections.sort(slices);
  Collections.reverse(slices);
  int i = 0;
  while (currentY < height) {
    //Slice img = slices.get((int) random(slices.size()));
    Slice img = slices.get(i);
    image(img.img, 0, currentY, width, img.h);
    currentY += img.h;
    i++;
  }
  slices.clear();
}


void sliceVerticalRandom() {
  int currentX = 0;
  while (currentX < width) {
    int randomSliceSize = (int) random(width/5);
    if (randomSliceSize + currentX > width) randomSliceSize = width - currentX;
    slice = get(currentX, 0, randomSliceSize, height);
    slices.add(new Slice(slice));
    currentX += randomSliceSize;
  }
  currentX = 0;
  Collections.sort(slices);
  Collections.reverse(slices);
  int i = 0;
  while (currentX < width) {
    Slice img = slices.get((int) random(slices.size()));
    image(img.img, currentX, 0, img.w, height);
    currentX += img.w;
    i++;
  }
  slices.clear();
}

void sliceCube(int _size) {
  for (int ix = 0; ix < round(width/_size); ix++) {
    for (int iy = 0; iy < (int) (height/_size); iy++) {
      slice = get(ix*_size, iy*_size, _size, _size);
      slices.add(new Slice(slice));
    }
  }
  Collections.sort(slices);
  int i=0;
  for (int ix = 0; ix < round(width/_size); ix++) {
    for (int iy = 0; iy < (int) (height/_size); iy++) {
      image(slices.get(i).img, ix*_size, iy*_size);
      i++;
    }
  }
  slices.clear();
}

void sliceVerticalReverse(int _slices) {
  int size = (int) (width/_slices);
  for (int i=0; i<_slices; i++) {
    slice = get(i*size, 0, size, height);
    slices.add(new Slice(slice));
  }
  for (int i=0; i<slices.size(); i++) {
    image(slices.get(slices.size()-i-1).img, i*size, 0);
  }
  slices.clear();
}


void sliceVertical(int _size) {
  int numberOfSlices = (int) (width/_size);
  for (int i=0; i<numberOfSlices; i++) {
    slice = get(i*_size, 0, _size, height);
    slices.add(new Slice(slice));
  }
  Collections.sort(slices);
  for (int i=0; i<slices.size(); i++) {
    image(slices.get(i).img, i*_size, 0);
  }
  slices.clear();
}

void sliceHorizontal(int _size) {
  int numberOfSlices = (int) (height/_size);
  for (int i=0; i<numberOfSlices; i++) {
    slice = get(0, i*_size, width, _size);
    slices.add(new Slice(slice));
  }
  Collections.sort(slices);
  for (int i=0; i<slices.size(); i++) {
    image(slices.get(i).img, 0, i*_size);
  }
  slices.clear();
}


