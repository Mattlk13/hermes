import processing.opengl.*;

import hermes.*;
import hermes.hshape.*;
import hermes.animation.*;
import hermes.physics.*;
import hermes.postoffice.*;

////////////////////////////////////////
// BEINGS
////////////////////////////////////////

/**
 * represents the stationary platforms in the game
 */
class Platform extends MassedBeing {
 
  static final float HEIGHT = 40.0f;              // the platform's height
  final color COLOR = color(125,125,125);  // the platform's color

  float width;   // width of this platform

  /**
   * makes a Platform with given center and width
   */
  Platform(PVector center, float width) {
    super(new Rectangle(center, width, HEIGHT), HermesMath.zeroVector(), HermesMath.INFINITY, 1);
    
    this.width = width;
  }
 
  void draw() {
    fill(COLOR);
    rect(0, 0, width, HEIGHT);
  }
 
}

/**
 * represents the player
 */
class Player extends MassedBeing {
  
  final static float PLAYER_WIDTH = 16;
  final static float PLAYER_HEIGHT = 36;
  final static float PLAYER_SPEED = 50;
  
  // constants used to indicate the direction the player is facing
  final static int FACING_LEFT = 1;
  final static int FACING_RIGHT = 2;
  
  int direction = FACING_RIGHT; // the direction the player is facing
  boolean jumped = false;       // whether the player can jump
  
  AnimatedSprite sprite;
  int animIndex;
  
  Player(float x, float y) {
    super(new Rectangle(HermesMath.makeVector(x, y), PLAYER_WIDTH, PLAYER_HEIGHT), HermesMath.zeroVector(), 1.0f, 1.0f);
    
    // load the animated character walk cycle
    sprite = new AnimatedSprite();
    Animation anim = new Animation("skeilert_walk_final", 1, 24, ".png", (int)(1000.0f / 24.0f));
    animIndex = sprite.addAnimation(anim);
    sprite.setActiveAnimation(animIndex);
    sprite.pause();
  }
  
  void draw() {
    scale(0.2);
    imageMode(CENTER);
    // if the character is facing left, invert the image
    if(direction == FACING_LEFT) {
      scale(-1,1);
      translate(20, 0);
    }
    image(sprite.animate(), 0, 0); // draw the current animation frame
  }
  
  // when this is called the player can jump again
  void resetJump() {
    jumped = false;
  }
  
  // we use update() to apply gravity
  void update() {
    addForce(
  }
  
  void handleKeyMessage(KeyMessage m) {
    int nKey = m.getKeyCode();
    if(m.isPressed()) { // the player's movement is controlled by w/a/s/d or the arrows
      if(nKey == POConstants.D || nKey == POConstants.RIGHT) {
        getVelocity().x = PLAYER_SPEED;
        direction = FACING_RIGHT;
        sprite.unpause();
      }
      if(nKey == POConstants.A || nKey == POConstants.LEFT) {
        getVelocity().x = -PLAYER_SPEED;
        direction = FACING_LEFT;
        sprite.unpause();
      }
      if((nKey == POConstants.W || nKey == POConstants.UP) && !_jumped) {
        addImpulse(HermesMath.makeVector(0, -2*PLAYER_SPEED));
        jumped = true;
      }
      if(nKey == POConstants.S || nKey == POConstants.DOWN) {
        getVelocity().y = 2*PLAYER_SPEED;
      }
    } else { // when a key is released, we stop the player
        if(nKey == POConstants.D || nKey == POConstants.A || nKey == POConstants.LEFT || nKey == POConstants.RIGHT) {
          getVelocity().x = 0;
          sprite.pause();
        }
    }
  } 
  
}

// used in platform generation 
// populates a rectangle with platforms 
// sector coordinates are on a scale of 1800 pixels/unit (1/sector)
static class Sector extends Being {
  
  final static int SECTOR_SIZE = 1800;    // pixel width of the sectors
  final static float VERTICAL_STEP = 120; // vertical space between platforms
  
  Rectangle rectangle;   // the rectangle
  
  int x, y;         // coordinates -- these are in sector space (1 unit per sector), not pixel space
  
  // creates a new sector at sector coors x,y, adds platforms to given PlatformGroup, with given density
  Sector(int x, int y, PlatformGroup platforms, float density) {
    super(rectOfSector(x,y));
    
    rectectagle = getBoundingBox();
    this.x = x;
    this.y = y;
    
    platforms.generatePlatforms(_rect, VERTICAL_STEP, density);
  }
  
  // the Rectangle defining the sector at this position
  static Rectangle rectOfSector(int x, int y) {
    return new Rectangle(new PVector((float)(x * SECTOR_SIZE), (float)(y * SECTOR_SIZE), 0), SECTOR_SIZE, SECTOR_SIZE);
  }
  
  // rectangles of the neighbors of this sector
  Rectangle[] getNeighborRects() {
    Rectangle[] rects = new Rectangle[8];
    rects[0] = rectOfSector(x, y - 1); // north
    rects[1] = rectOfSector(x, y + 1); // south
    rects[2] = rectOfSector(x + 1, y); // east
    rects[3] = rectOfSector(x - 1, y); // west
    rects[4] = rectOfSector(x + 1, y - 1); // NE
    rects[5] = rectOfSector(x + 1, y + 1); // SE
    rects[6] = rectOfSector(x - 1, y - 1); // NW
    rects[7] = rectOfSector(x - 1, y + 1); // SW
    
    return rects;
  }
    
}

// stores the sectors in the game, holding them in a Hashtable
// this allows for storage of an indefinite number of sectors, allocated on the fly
class SectorGrid extends Being {
 
  Hashtable<Integer, Sector> sectors;  // all the sectors, hashed by a number derived from their coordinates
  Sector currentSector;                // the current sector containing the character

  // sets up the grid with a starting sector
  SectorGrid(Sector first) {
      super(first.rectangle);
      sectors = new Hashtable<Integer, Sector>(); 
      currentSector = first;
      sectors.put(packCoors(first.x, first.y), first);
  }
    
  Sector getCurrentSector() {
   return currentSector;
  }
  
  void setCurrentSector(Sector sector) {
    currentSector = sector;
  }

  Hashtable<Integer, Sector> getSectors() {
    return sectors;
  }
  
}

// used for generating the hash code for sectors
Integer packCoors(int x, int y) {
   return new Integer(x ^ y << 16);
}

///////////////////////////////////////////////
// GROUPS
///////////////////////////////////////////////

/**
 * generates and stores the platforms in the game
 */
class PlatformGroup extends Group<Platform> {
  
  PlatformGroup(World world) { 
    super(world);
    
  }
  
  /**
   * adds a platform at given center and width
   */
  void addPlatform(PVector center, float width) {
    Platform platform = new Platform(center, width);
    world.registerBeing(platform, false);
    this.add(platform);
  }
  
  /**
   * fills an area with randomly-placed platforms
   */
  void generatePlatforms(Rectangle area, float verticalStep, float density) {
    float boxWidth = area.getRectWidth();
    float boxHeight = area.getRectHeight();
    float maxPlatWidth = boxWidth / 2;
    float minPlatWidth = Platform.HEIGHT * 2;
    // iterate through rows
    for(float y = area.getAbsMin().y + verticalStep; y <= area.getAbsMax().y - verticalStep; y += verticalStep) {
      float x = area.getAbsMin().x; // start at the left end of the rect
      float platWidth = random(minPlatWidth, maxPlatWidth); // width of the new platform
      float baseDist = random(minPlatWidth, maxPlatWidth);  // distance before the new platform
      x += platWidth / 2 + baseDist / density;              // move to the midpoint of the new platform
      while(x < area.getAbsMax().x - platWidth / 2) {       // keep going right until a platform would leave the rect
        addPlatform(makeVector(x, y), platWidth);
        x += platWidth / 2;
        platWidth = random(minPlatWidth, maxPlatWidth);
        baseDist = random(minPlatWidth, maxPlatWidth);
        x += platWidth / 2 + baseDist / density;
      }
    }  
  }
  
  
}

///////////////////////////////////////////////////
// Interactors
///////////////////////////////////////////////////

// handles player-platform collisions
class PlatformCollider extends GenericMassedCollider<Player, Platform> {
  
  PlatformCollider(float elasticity) {
    super(elasticity);
  }
  
  // reset the player's jump when he hits a platform, then do the normal projection/impulse collision stuff
  void handle(Player player, Platform platform) {
    player.resetJump(); // reset the jump
    super.handle(player, platform); // have GenericMassedCollider do the rest
  }
  
}

// generates platforms when the camera enters an unexplored area
class PlatformGenerator implements Interactor<SectorGrid, Camera> {
        
   PlatformGroup platformGroup;      // group to add platforms to
   
   PlatformGenerator(PlatformGroup group) {
    platformGroup = group;
   }
    
   boolean detect(SectorGrid grid, Camera cam) {
     // we only need to do anything if the camera's box is not completely contained by the current sector
     return !grid.getCurrentSector().getBoundingBox().contains(cam.getBoundingBox());
   }
    
   boolean handle(SectorGrid grid, Camera cam) {
     Sector current = grid.getCurrentSector();
     Hashtable<Integer,Sector> sectors = grid.getSectors();
     // see which neighbors of this sector the camera overlaps with
     Rectangle[] neighbors = current.getNeighborRects();
     for(int i = 0; i < 8; i++) {
       if(cam.getBoundingBox().collide(neighbors[i])) {
         int x = (int)neighbors[i].getPosition().x / Sector.SECTOR_SIZE;
         int y = (int)neighbors[i].getPosition().y / Sector.SECTOR_SIZE;
         // see if we've visited this sector yet
         if(sectors.get(packCoors(x,y)) == null) {
           // if not, generate platforms for it
           sectors.put(packCoors(x,y), new Sector(x, y, platformGroup, random(0.5, 1)));
         }
         // if the camera center is in a new bounding box, we need to change the current sector
         if(neighbors[i].contains(cam.getBoundingBox().getCenter()))
           grid.setCurrentSector(sectors.get(packCoors(x,y)));
       }
     }
     return true;
   }
  
}


///////////////////////////////////////////////////
// DEFINE
///////////////////////////////////////////////////

static final int WINDOW_WIDTH = 600;
static final int WINDOW_HEIGHT = 600;

///////////////////////////////////////////////////
// GLOBAL VARS
///////////////////////////////////////////////////

World world;
Camera cam;
PostOffice po;
PlatformGroup platforms;
Player player;

///////////////////////////////////////////////////
// PAPPLET
///////////////////////////////////////////////////

void setup() {
  size(WINDOW_WIDTH, WINDOW_HEIGHT, JAVA2D);  // set window size
  Hermes.setPApplet(this);            // give the library the PApplet
  
  // set up the world, camera, and post office
  cam = new Camera();
  po = new PostOffice();
  world = new World(po, cam);
  
  rectMode(CENTER);
  
  Rectangle initialBounds = new Rectangle(HermesMath.zeroVector(), HermesMath.INFINITY, HermesMath.INFINITY);
  
  // set up the platforms
  platforms = new PlatformGroup(world);
  Sector first = new Sector(0, 0, platforms, 0.8);
  SectorGrid grid = new SectorGrid(first);
  
  // set up platform generation
  world.registerInteraction(grid, cam, new PlatformGenerator(platforms), true);
  
  // set up the player
  player = new Player(0, 60);  
  world.registerBeing(player, true);
  po.registerKeySubscription(player, POConstants.W);
  po.registerKeySubscription(player, POConstants.A);
  po.registerKeySubscription(player, POConstants.S);
  po.registerKeySubscription(player, POConstants.D);
  po.registerKeySubscription(player, POConstants.UP);
  po.registerKeySubscription(player, POConstants.DOWN);
  po.registerKeySubscription(player, POConstants.LEFT);
  po.registerKeySubscription(player, POConstants.RIGHT);
  
  // make player collide with platforms
  world.registerInteraction(player, platforms, new PlatformCollider(0), false);
  
  frameRate(48);
  
  // run it!
  world.start();
}

void draw() {
  background(230);
  
  // lock the camera to the player
  cam.setPosition(player.getPosition().x - WINDOW_WIDTH / 2, player.getPosition().y - WINDOW_HEIGHT / 2);
  
  cam.draw(); // draw the world
}
