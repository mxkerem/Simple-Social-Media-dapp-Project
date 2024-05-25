import Map "mo:base/HashMap";
import Hash "mo:base/Hash";
import Nat "mo:base/Nat";
import Iter "mo:base/Iter";
import Text "mo:base/Text";
import Time "mo:base/Time";
import Principal "mo:base/Principal";

actor SocialMedia {

  type Post = {
    author : Principal;
    content : Text;
    timestamp : Time.Time;
    likes : Nat;
  };

  func natHash(n : Nat) : Hash.Hash {
    Text.hash(Nat.toText(n));
  };

  var posts = Map.HashMap<Nat, Post>(0, Nat.equal, natHash);
  var nextId : Nat = 0;

  public query func getPosts() : async [(Nat, Post)] {
    Iter.toArray(posts.entries());
  };

  public shared (msg) func addPost(content : Text) : async Text {

    let id = nextId;
    posts.put(id, { author = msg.caller; content = content; timestamp = Time.now(); likes = 0});
    nextId += 1;
    "Gönderi başarıyla eklendi. Gonderiyi editlemek begenileri sifirlar. Gönderi ID'si: " # Nat.toText(id);

  };

  public query func ViewPost(id : Nat) : async ?Post {
    posts.get(id);
  };

  public func clearPosts() : async (){
    for (key : Nat in posts.keys()){
      ignore posts.remove(key);
    };
  };

  public shared (msg) func editPost(id : Nat, newContent : Text) : async Bool{
    switch(posts.get(id)) {
      case(?post) { 
        if (post. author == msg.caller) {
          posts.put(id, {author = msg.caller; content = newContent; timestamp = post.timestamp; likes = 0 });
          return true;
        } else {
          return false;
        };
       };
      case null{
        return false;
       };
    };
  };

  type Comment = {
    cAuthor : Principal;
    cContent : Text;
    cTimestamp : Time.Time;
    vote : Bool;
    postId : Nat;
  };

  var comments = Map.HashMap<Nat, Comment>(0, Nat.equal, natHash);
  var nextcId : Nat = 0;

  public shared (msg) func addComment(postId : Nat, cContent : Text, vote : Bool) : async Text {
    switch(posts.get(postId)) {
    case(?post) {
      let cId = nextcId;
      comments.put(cId, {postId = postId; cAuthor = msg.caller; cContent = cContent; vote = vote; cTimestamp = Time.now()});
      nextcId += 1;
      if (vote) {
        let updatedPost = {post with likes = post.likes + 1};
        posts.put(postId, updatedPost);
      };
      "Yorum başarıyla eklendi. Yorum ID'si: " # Nat.toText(cId);
    };
    case null {
      "Gecersiz post ID.";
    };
  };
  };

  public query func ViewComment(cId : Nat) : async ?Comment {
    comments.get(cId);
  };
 
  public query func ViewMostLikedPost() : async ?(Nat, Post) {
  var mostLiked : ?(Nat, Post) = null;
  for ((id, post) in posts.entries()) {
    switch mostLiked {
      case null {
        mostLiked := ?(id, post);
      };
      case (?(_, currentMostLikedPost)) {
        if (post.likes > currentMostLikedPost.likes) {
          mostLiked := ?(id, post);
        };
      };
    };
  };
  mostLiked;
};
}
