package com.gameroad.graphics 
{
	import away3d.animators.SkinAnimation;
	import away3d.core.base.Mesh;
	import away3d.core.base.Object3D;
	import away3d.events.Loader3DEvent;
	import away3d.loaders.Collada;
	import away3d.loaders.Loader3D;
	import away3d.materials.ITriangleMaterial;
	import away3d.materials.WireColorMaterial;
	import flash.display.DisplayObjectContainer;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.utils.Dictionary;
	
	/**
	 * DAE
	 * 
	 * @author Jorge Miranda
	 */
	public class DAE extends EventDispatcher
	{
		/***** Constants *****/
		
		public static var DEFAULT_MATERIAL	:ITriangleMaterial = new WireColorMaterial(0xff0000);
		
		
		/***** Private Variables *****/
		
		protected var _path				:String;
		protected var _collada			:Collada;
		protected var _loader			:Loader3D;
		protected var _animation		:SkinAnimation;
		protected var _mesh				:Object3D;
		protected var _animations		:Dictionary;
		protected var _currentAnimation	:AnimationCue;
		protected var _currentTime		:Number;
		protected var _endTime			:Number;
		protected var _playing			:Boolean;
		protected var _loop				:Boolean;
		protected var _loaded			:Boolean;
		protected var _material			:ITriangleMaterial;
		
		
		/***** Public Properties *****/
		
		public function get isLoaded() :Boolean { return _loaded; }
		public function get isPlaying() :Boolean { return _playing; }		
		public function get currentTime() :Number { return _currentTime; }
		public function get material() :ITriangleMaterial { return _material; }
		public function set material(value:ITriangleMaterial) :void { _material = value; }
		public function get loader():Object3D { return _loader; }
		public function get mesh():Object3D { return _mesh; }
		
		
		/***** Public Methods *****/
		
		/**
		 * Constructor.
		 */
		public function DAE() 
		{
			trace("hola");
			_playing = false;
			_loop = false;
			_loaded = false;
			_currentTime = 0;
			_animations = new Dictionary();
			_collada = new Collada();
			_collada.centerMeshes = true;	
		}
		
		
		/**
		 * Load a Collada file.
		 * 
		 * @param	path		The path to the file with the Collada content.
		 * @param	material	The material used with the content.
		 */
		public function load(path :String,  material :ITriangleMaterial = null) :void
		{
			_loaded = false;
			_path = path;
			_material = (material)? material : DEFAULT_MATERIAL;
			_collada.material = _material;
			
			_loader = new Loader3D();
			_loader.loadGeometry(_path, _collada);
			_loader.addEventListener(Loader3DEvent.LOAD_SUCCESS, onLoadComplete);
		}
		
		
		/**
		 * Retrieve the collada data from a given collada document.
		 * 
		 * @param	data		The object to parse (usually, an XML instance with the Collada document).
		 * @param	material	The material used with the parsed content.
		 */
		public function parse(data :*, material :ITriangleMaterial = null) :void
		{
			_loaded = false;
			_material = (material)? material : DEFAULT_MATERIAL;
			_collada.material = _material;
			_mesh = _collada.parse(data);
			
			initCollada();
		}
		
		
		/**
		 * Add a new animation cue to the DAE container.
		 * 
		 * @param	name	The animation's identifier.
		 * @param	start	Start time.
		 * @param	end		End time.
		 * @param	speed	The Playback speed.
		 */
		public function addAnimation(name :String, start :Number, end :Number, speed :Number = 1):void
		{
			if (!_loaded) return;
			_animations[name] = new AnimationCue(name, start, end, speed);
		}
		
		
		/**
		 * Play the given animation.
		 * 
		 * @param	name	The animation's identifier.
		 * @param	loop	If true, the animation will loop.
		 */
		public function playAnimation(name :String, loop :Boolean = false ):void
		{
			if (!_loaded) return;
			
			if (_currentAnimation && _currentAnimation.name == name) return;
			
			if (!_animations[name]) {
				
				trace("Error on Dae::playAnimation(): Animation '" + name + "' doesn´t exists.") ;  return;
			}
			
			_currentAnimation = _animations[name];
			_loop = loop;
			_currentTime = _currentAnimation.start;
			_endTime = _currentAnimation.end;
			_playing = true;			
		}
		
		
		/**
		 * Stop the the animation's playback.
		 */
		public function stopAnimation():void
		{
			if (!_loaded) return;
			_playing = false;
		}
		
		
		/**
		 * Update the playback time.
		 * 
		 * @param	elapsed	The time elapsed since the last update.
		 */
		public function updateAnimation(elapsed :Number):void
		{
			if (!_loaded) return;
			
			if (_playing) {
				_currentTime += elapsed * _currentAnimation.speed;
				
				if (_currentTime >= _endTime)
				{
					if (_loop)
					{
						_currentTime = _currentAnimation.start + _currentTime - _endTime;
					}
					else
					{
						_playing = false;						
						_currentTime = _currentAnimation.end;
					}
				}
				
				_animation.update(_currentTime);	
			}
		}
		
		
		/***** Private Methods *****/
		
		/**
		 * Initialize the loaded Collada data.
		 */
		private function initCollada() :void
		{
			_loaded = true;
			
			if (_mesh.animationLibrary.getAnimation("default")) {
				
				_animation = _mesh.animationLibrary.getAnimation("default").animation as SkinAnimation;
			}
		}
		
		
		/**
		 * Dispatched qhen the model was completely loaded
		 * 
		 * @param	e Loader3DEvent
		 */
		private function onLoadComplete(e :Loader3DEvent) :void 
		{
			_loader.removeEventListener(Loader3DEvent.LOAD_SUCCESS, onLoadComplete);
			_mesh = _loader.handle;				
			initCollada();
			
			this.dispatchEvent(new Event(Event.COMPLETE));
		}
	}
}


/**
 * Stores the playback info, for a single animation.
 */
internal class AnimationCue
{
	public var name		:String;
	public var start	:Number;
	public var end		:Number;
	public var speed	:Number;
	
	/**
	 * Constructor.
	 */
	public function AnimationCue(name :String, start :Number, end :Number, speed :Number)
	{
		this.name = name;
		this.start = start;
		this.end = end;
		this.speed = speed;
	}
}